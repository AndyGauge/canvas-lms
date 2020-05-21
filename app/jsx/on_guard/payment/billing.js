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
import {Tray} from '@instructure/ui-overlays'
import {TabList} from '@instructure/ui-tabs'
import {Table} from '@instructure/ui-elements'

class PaymentBilling extends Component {
  constructor(props) {
    super(props)

    this.state = {
      subscription: {},
      item: {},
      invoices: [],
      end_of_month: "",
      users_not_invoiced_count: 0,
    }
  }

  componentDidMount() {
    this.fetchController = new AbortController()
    const signal = this.fetchController.signal
    fetch('/on_guard/billing/stripe', {signal})
      .then(response => response.json())
      .then(striperes => this.setState({
          subscription: JSON.parse(striperes['subscription']),
          item: JSON.parse(striperes['item']),
          invoices: JSON.parse(striperes['invoices']),
          end_of_month: striperes['end_of_month'],
          users_not_invoiced_count: striperes['users_not_invoiced_count']
        })
      )
  }

  onTabChanged = (newIndex, oldIndex) => {
    /* if (newIndex === oldIndex) return
    const newContextType = newIndex === COURSE_TAB_INDEX ? COURSE : ACCOUNT
    this.props.filterRoles({
      selectedRoles: [{value: ALL_ROLES_VALUE, label: ALL_ROLES_LABEL}],
      contextType: this.state.contextType
    })
    this.setState(
      {
        permissionSearchString: '',

        contextType: newContextType
      },
      () => {
        this.props.tabChanged(newContextType)
      }
    ) */
  }

  render() {
    let ending_date
    let quantity
    if (this.state.subscription) {
      ending_date = new Date(
        this.state.subscription.current_period_end * 1000
      ).toLocaleDateString('en-us')
      quantity = this.state.item.quantity
    }

    return (
      <div>
        <ScreenReaderContent>
          <h1>Billing</h1>
        </ScreenReaderContent>
        <TabList onChange={this.onTabChanged}>
          <TabList.Panel title="Summary">
            <p>On Guard bills $1 when you sign up, that covers your security training.</p>
            <p>Add users at any time.  We charge for those users at the end of every month</p>
            <p>On {ending_date}, {quantity} user{quantity == 1 ? '' : 's'} will be renewed.</p>
            <p>On {this.state.end_of_month}, {this.state.users_not_invoiced_count} new users will be invoiced.</p>
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
          <TabList.Panel title="Payment Method" />
        </TabList>
      </div>
    )
  }
}

export default PaymentBilling
