import React from 'react';
import ReactDOM from 'react-dom';
import {Elements} from '@stripe/react-stripe-js';
import {loadStripe} from '@stripe/stripe-js';

import PaymentSignup from '../on_guard/payment/sign_up_form';

const stripePromise = loadStripe("pk_test_u9GdTvcNq92kCmp7khlDrnRz007AyPREka");

function App() {
  return (
    <Elements stripe={stripePromise}>
      <PaymentSignup />
    </Elements>
  );
};

ReactDOM.render(<App />, document.getElementById('root'));
