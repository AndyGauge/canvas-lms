/*
 * Copyright (C) 2020 - present Instructure, Inc.
 *
 * This file is part of Canvas.
 *
 * Canvas is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Affero General Public License as published by the Free
 * Software Foundation, version 3 of the License.
 *
 * Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Affero General Public License along
 * with this program. If not, see <http://www.gnu.org/licenses/>.
 */

import React, {Component} from 'react'
import {ScreenReaderContent} from '@instructure/ui-a11y'
import {TabList} from '@instructure/ui-tabs'
import {Table} from '@instructure/ui-elements'
import {CardElement} from '@stripe/react-stripe-js'

class PaymentBilling extends Component {
  constructor(props) {
    super(props)

    this.state = {
      subscription: {},
      item: {},
      invoices: [],
      card: {},
      end_of_month: '',
      users_not_invoiced_count: 0,
      stripe_invalid: false,
      payment_updated: false,
      error: {}
    }

    this.handleCardElementChanged = this.handleCardElementChanged.bind(this)
    this.handleUpdatePayment = this.handleUpdatePayment.bind(this)
  }

  componentDidMount() {
    this.latestStripe()
  }

  latestStripe = () => {
    this.fetchController = new AbortController()
    const signal = this.fetchController.signal
    fetch('/on_guard/billing/stripe', {signal})
      .then(response => response.json())
      .catch(error =>
        setState({error: {message: 'Failed to contact On Guard servers, try again soon.'}})
      )
      .then(striperes => {
        const subscription = striperes.subscription
        this.setState({
          subscription,
          item: striperes.item,
          invoices: striperes.invoices,
          card: striperes.card,
          end_of_month: new Date(striperes.end_of_month.split('-')).toLocaleDateString('en-us'),
          users_not_invoiced_count: striperes.users_not_invoiced_count
        })
      })
  }

  onTabChanged = (newIndex, oldIndex) => {}

  handleCardElementChanged = e => {
    this.setState({stripe_invalid: Boolean(e.error), payment_updated: false})
  }

  handleUpdatePayment = async e => {
    e.preventDefault()

    const {stripe, elements} = this.props
    if (!stripe || !elements) {
      return
    }
    const cardElement = elements.getElement(CardElement)

    const {error, paymentMethod} = await stripe.createPaymentMethod({
      type: 'card',
      card: cardElement
    })
    if (error) {
      this.setState({error})
    } else {
      const form = new FormData()
      form.append('payment_method', paymentMethod.id)
      fetch('/on_guard/billing/update_payment', {
        method: 'POST',
        body: form
      })
        .then(response => response.json())
        .catch(error =>
          this.setState({error: {message: 'unable to contact On Guard servers, try again soon.'}})
        )
        .then(status => {
          if (status.status == 'ok') {
            this.setState({payment_updated: true})
            this.latestStripe()
          } else {
            this.setState({error: status.error})
          }
        })
    }
  }

  render() {
    let ending_date
    let quantity = 0
    let display_block = false
    if (this.state.subscription.current_period_end) {
      ending_date = new Date(this.state.subscription.current_period_end * 1000).toLocaleDateString(
        'en-us'
      )
      quantity = this.state.item.quantity
      if (ending_date > this.state.end_of_month) {
        quantity += this.state.users_not_invoiced_count
      }
      display_block = true
    }
    const {stripe} = this.props

    let alert = <div />
    if (typeof this.state.error.message !== 'undefined') {
      alert = <div className="ErrorAlert">{this.state.error.message}</div>
    }
    if (this.state.payment_updated) {
      alert = <div className="SuccessAlert">Payment Method successfully updated</div>
    }

    return (
      <div>
        <ScreenReaderContent>
          <h1>Billing</h1>
        </ScreenReaderContent>
        <TabList onChange={this.onTabChanged}>
          <TabList.Panel title="Summary">
            <div className="reminder" style={{marginBottom: '30px', maxWidth: 400}}>
              <h2 style={{textAlign: 'center'}}>{this.props.billing_plan.name}</h2>
              <div className="body">
                <p>{this.props.billing_plan.description}</p>
                <h3 style={{textAlign: 'center'}}>{this.props.billing_plan.display_price}</h3>
              </div>
            </div>
            <div style={{marginBottom: '30px'}}>
              <h3>Upcoming Charges</h3>

              {display_block && (
                <div style={{marginLeft: '20px'}}>
                  <p>On {ending_date}, your subscription will be renewed. </p>
                </div>
              )}
            </div>
            <div style={{marginLeft: '20px'}}>
              <p>
                Additional Questions? <a href="mailto:support@on-guard.org">Send us an email</a>
              </p>
            </div>
          </TabList.Panel>
          <TabList.Panel title="History">
            <Table margin="small 0" caption={<ScreenReaderContent />}>
              <thead>
                <tr>
                  <td>Date</td>
                  <td>Amount</td>
                  <td>Download</td>
                </tr>
              </thead>
              <tbody>
                {this.state.invoices.map(invoice => (
                  <tr key={invoice.id}>
                    <td>{new Date(invoice.created * 1000).toLocaleDateString('en-us')}</td>
                    <td> $ {invoice.amount_paid / 100}</td>
                    <td>
                      <a href={invoice.invoice_pdf}>
                        <img src="/images/onguard/invoice.png" style={{height: 32, width: 32}} />
                      </a>
                    </td>
                  </tr>
                ))}
              </tbody>
            </Table>
          </TabList.Panel>
          <TabList.Panel title="Payment Method">
            <div style={{fontWeight: 'bold', marginBottom: '20px'}}>Current Payment Card:</div>
            <div style={{marginLeft: '20px', marginBottom: '30px'}}>
              ****-****-****-{this.state.card.last4} ({this.state.card.brand})
            </div>
            <form onSubmit={this.handleUpdatePayment}>
              <div style={{fontWeight: 'bold', marginBottom: '20px'}}>Update Payment Card: </div>
              <div className="HalfPayment" style={{marginLeft: '20px'}}>
                <div
                  style={
                    this.state.stripe_invalid
                      ? {
                          border: '0.0625rem solid #EE0612',
                          borderRadius: '0.25rem',
                          padding: '10px 20px',
                          marginBottom: '15px'
                        }
                      : {
                          border: '0.0625rem solid #C7CDD1',
                          borderRadius: '0.25rem',
                          padding: '10px 20px',
                          marginBottom: '15px'
                        }
                  }
                >
                  <CardElement
                    options={{
                      style: {
                        base: {
                          fontSize: '16px',
                          color: '#2D3B45',
                          fontFamily: 'Latoweb, Lato, Helvetica Neue, Helvetica, Arial, sans-serif',
                          fontWeight: 400
                        }
                      }
                    }}
                    onChange={this.handleCardElementChanged}
                  />
                </div>

                <div>
                  <button className="btn btn-primary" type="submit" disabled={!stripe}>
                    Update
                  </button>
                </div>
              </div>
              {alert}
            </form>
          </TabList.Panel>
        </TabList>
      </div>
    )
  }
}

export default PaymentBilling
