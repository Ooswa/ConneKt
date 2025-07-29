const express = require('express');
const Stripe = require('stripe');
const cors = require('cors');

const app = express();

// ✅ DIRECTLY using your actual Stripe secret key here
const stripe = Stripe('YOUR_KEY');

app.use(cors());
app.use(express.json());

app.post('/create-payment-intent', async (req, res) => {
  const { amount } = req.body;

  try {
    const paymentIntent = await stripe.paymentIntents.create({
      amount,
      currency: 'pkr',
      payment_method_types: ['card'],
    });

    return res.send({ clientSecret: paymentIntent.client_secret });
  } catch (error) {
    console.error(error);
    res.status(500).send({ error: error.message });
  }
});


app.listen(4242, '0.0.0.0', () => console.log('✅ Server running on port 4242'));
