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

import React, {useState} from 'react'
import {useStripe, useElements, CardElement} from '@stripe/react-stripe-js'
import Modal from '../../shared/components/InstuiModal'
import {Button} from '@instructure/ui-buttons'
import ClimbingBoxLoader from 'react-spinners/ClimbingBoxLoader';
import {FormFieldGroup} from '@instructure/ui-form-field'
import {TextInput} from '@instructure/ui-text-input'

export default function PaymentSignup() {
  const [name, setName] = useState('')
  const [email, setEmail] = useState('')
  const [organization, setOrganization] = useState('')
  const [password, setPassword] = useState('')
  const [passwordConfirmation, setPasswordConfirmation] = useState('')
  const [loading, setLoading] = useState(false)
  const [status, setStatus] = useState('')
  const stripe = useStripe()
  const elements = useElements()

  const handleSubmit = async event => {
    event.preventDefault()
    if (!stripe || !elements) {
      return
    }
    const cardElement = elements.getElement('card')
    stripe
      .createPaymentMethod({
        type: 'card',
        card: cardElement,
        billing_details: {name}
      })
      .then(({paymentMethod}) => {
        setLoading(true)
        fetch('/on_guard/sign_up/', {
          method: 'post',
          body: JSON.stringify({
            user: {name, email},
            organization,
            password,
            passwordConfirmation,
            paymentMethod
          }),
          headers: {
            'Content-Type': 'application/json'
          }
        })
          .then(response => response.json())
          .then(data => {
              setStatus(data.status)
              setLoading(false)
          })
          .catch(error => {
            setStatus('error')
          })
      })
  }

  switch(status) {
    case 'active':
      return ('<div />');
      break;
    default:
      return (
        <div>
          <div className={'loading-spinner'}>
            <ClimbingBoxLoader
              size={20}
              color={'#D7B236'}
              loading={loading}
              css={`display: block;
          position: fixed;
          z-index: 10099;
          margin-left: -4em;
          margin-top: -3.5em;
          left: 50%;
          top: 50%;`}
            />
          </div>
          <Modal
            as="form"
            onSubmit={handleSubmit}
            open
            size="small"
            label="Sign Up"
            shouldCloseOnDocumentClick={false}
          >
            <Modal.Body>
              <FormFieldGroup layout="stacked" rowSpacing="small" description="">
                <TextInput
                  renderLabel="Your Company/Organization"
                  value={organization}
                  onChange={e => setOrganization(e.target.value)}
                />

                <TextInput renderLabel="Name" value={name} onChange={e => setName(e.target.value)}/>
                <TextInput renderLabel="E-mail" value={email} onChange={e => setEmail(e.target.value)}/>
                <TextInput
                  renderLabel="Password"
                  value={password}
                  onChange={e => setPassword(e.target.value)}
                  type="password"
                />
                <TextInput
                  renderLabel="Password Confirmation"
                  value={passwordConfirmation}
                  onChange={e => setPasswordConfirmation(e.target.value)}
                  type="password"
                />
              </FormFieldGroup>
              <span className="cMIPy_bGBk">
          <span className="bNerA_bGBk bNerA_NmrE bNerA_dBtH bNerA_bBOa bNerA_buDT bNerA_DpxJ">
            <span className="fCrpb_bGBk fCrpb_egrg">Payment Details</span>
          </span>
        </span>
              <div
                style={{border: '0.0625rem solid #C7CDD1', borderRadius: '0.25rem', padding: '10px 20px'}}
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
                />
              </div>
            </Modal.Body>
            <Modal.Footer>
              <Button>Cancel</Button> &nbsp;
              <Button type="submit" variant="primary">
                Sign Up
              </Button>
            </Modal.Footer>
          </Modal>
        </div>
      )
  }
}
