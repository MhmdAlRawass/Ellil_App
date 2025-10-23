/* eslint-disable */
require("dotenv").config();
const admin = require("firebase-admin");
// Initialize Firebase Admin at top-level
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
  });
}

const { onCall } = require("firebase-functions/v2/https");
const functions = require("firebase-functions");
const logger = require("firebase-functions/logger");
const stripe = require("stripe")(process.env.STRIPE_SECRET_KEY);

exports.getStripePrices = onCall(async (request) => {
  try {
    const prices = await stripe.prices.list({
      expand: ["data.product"],
      active: true,
    });

    return prices.data.map((price) => ({
      id: price.id,
      nickname: price.nickname || price.product.name || "Untitled",
      amount: price.unit_amount ? price.unit_amount / 100 : 0,
      currency: price.currency || "usd",
      interval: price.recurring ? price.recurring.interval : "one-time",
    }));
  } catch (error) {
    logger.error("Error fetching Stripe prices:", error);
    throw new Error(error.message);
  }
});

exports.createPaymentIntent = onCall(async (request) => {
  try {
    let { priceId, customerId } = request.data;

    // --- CUSTOMER LOGIC ---
    let customer;
    if (customerId) {
      try {
        customer = await stripe.customers.retrieve(customerId);
      } catch (err) {
        logger.warn(
          `Customer ID "${customerId}" not found, creating a new customer`
        );
        customer = await stripe.customers.create({
          description: "New Customer",
        });
        customerId = customer.id;
      }
    } else {
      customer = await stripe.customers.create({
        description: "New Customer",
      });
      customerId = customer.id;
    }

    // --- PRICE LOGIC ---
    let amount = 100;
    let currency = "usd";
    let description = "Test Payment";
    let interval = "month";
    let intervalCount = 2;

    if (priceId) {
      try {
        const price = await stripe.prices.retrieve(priceId);
        amount = price.unit_amount || 100;
        currency = price.currency || "usd";
        description = `Subscription: ${price.nickname || "Plan"}`;
        interval = price.recurring.interval || "month";
        intervalCount = price.recurring.interval_count || 2;
      } catch (err) {
        logger.warn(
          `Price ID "${priceId}" not found, using default test values`
        );
      }
    }

    // --- CREATE PAYMENT INTENT ---
    const paymentIntent = await stripe.paymentIntents.create({
      amount,
      currency,
      customer: customerId,
      payment_method_types: ["card"],
      description,
    });

    // --- CREATE EPHEMERAL KEY ---
    const ephemeralKey = await stripe.ephemeralKeys.create(
      { customer: customerId },
      { apiVersion: "2022-11-15" }
    );

    return {
      clientSecret: paymentIntent.client_secret,
      customerId,
      ephemeralKey: ephemeralKey.secret,
      interval,
      intervalCount,
      testMode: !priceId,
    };
  } catch (error) {
    logger.error("Error creating payment intent:", error);
    throw new Error(error.message);
  }
});

exports.createBookPaymentIntent = onCall(async (request) => {
  try {
    const { userId, bookId } = request.data;
    if (!userId || !bookId) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Missing userId or bookId"
      );
    }

    // 1️⃣ Fetch book
    const bookSnap = await admin
      .firestore()
      .collection("books")
      .doc(bookId)
      .get();
    if (!bookSnap.exists) {
      throw new functions.https.HttpsError("not-found", "Book not found");
    }
    const book = bookSnap.data();
    const amount = Math.round((book.price || 0) * 100);
    if (amount <= 0) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Invalid book price"
      );
    }

    // check if book is already purchased
    const historySnap = await admin
      .firestore()
      .collection("users")
      .doc(userId)
      .collection("booksHistory")
      .where("bookId", "==", bookId)
      .get();

    if (!historySnap.empty) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Book already purchased"
      );
    }

    // 2️⃣ Get or create Stripe customer
    let customerId;
    const userDoc = await admin
      .firestore()
      .collection("users")
      .doc(userId)
      .get();
    if (userDoc.exists && userDoc.data().stripeCustomerId) {
      customerId = userDoc.data().stripeCustomerId;
    } else {
      const customer = await stripe.customers.create({
        metadata: { firebaseUID: userId },
      });
      customerId = customer.id;
      // Use set with merge to avoid NOT_FOUND
      await admin
        .firestore()
        .collection("users")
        .doc(userId)
        .set({ stripeCustomerId: customerId }, { merge: true });
    }

    // 3️⃣ Create PaymentIntent
    const paymentIntent = await stripe.paymentIntents.create({
      amount,
      currency: "usd",
      customer: customerId,
      payment_method_types: ["card"],
      description: `Purchase of book: ${book.name}`,
      metadata: { userId, bookId },
    });

    return { clientSecret: paymentIntent.client_secret, customerId };
  } catch (error) {
    console.error("Error creating book payment intent:", error);
    throw new functions.https.HttpsError("internal", error.message, {
      stack: error.stack,
    });
  }
});

exports.stripeWebhook = require("firebase-functions/v2/https").onRequest(
  async (req, res) => {
    let event;
    const webhookSecret =
      process.env.STRIPE_WEBHOOK_SECRET || process.env.stripe_webhook_secret;

    try {
      const sig = req.headers["stripe-signature"];
      event = stripe.webhooks.constructEvent(req.rawBody, sig, webhookSecret);
    } catch (err) {
      return res.status(400).send(`Webhook Error: ${err.message}`);
    }

    if (event.type === "payment_intent.succeeded") {
      const paymentIntent = event.data.object;
      const { userId, bookId } = paymentIntent.metadata;

      // ✅ Mark the book as purchased
      await admin
        .firestore()
        .collection("users")
        .doc(userId)
        .collection("booksPurchased")
        .add({
          userId: userId,
          bookId: bookId,
          purchasedAt: new Date(),
          pricePaid: paymentIntent.amount / 100,
        });
    }

    res.json({ received: true });
  }
);
