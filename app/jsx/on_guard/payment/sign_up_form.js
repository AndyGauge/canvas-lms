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

import React, {useState, Fragment} from 'react'
import {useStripe, useElements, CardElement} from '@stripe/react-stripe-js'
import Modal from '../../shared/components/InstuiModal'
import {Button} from '@instructure/ui-buttons'
import {Billboard} from '@instructure/ui-billboard'
import ClimbingBoxLoader from 'react-spinners/ClimbingBoxLoader'
import {FileDrop} from '@instructure/ui-forms'
import {FormFieldGroup} from '@instructure/ui-form-field'
import {Flex, Grid} from '@instructure/ui-layout'
import {showFlashAlert, showFlashError} from '../../shared/FlashAlert'
import {Text} from '@instructure/ui-elements'
import {TextInput} from '@instructure/ui-text-input'
import {uploadFiles} from '../../shared/upload_file'

export default function PaymentSignup() {
  const [name, setName] = useState('')
  const [email, setEmail] = useState('')
  const [organization, setOrganization] = useState('')
  const [password, setPassword] = useState('')
  const [passwordConfirmation, setPasswordConfirmation] = useState('')
  const [loading, setLoading] = useState(false)
  const [status, setStatus] = useState('import')
  const [users, setUsers] = useState([])
  const [newUser, setNewUser] = useState('')
  const [newEmail, setNewEmail] = useState('')
  const [err, setErr] = useState({});
  const [fileMessages, setFileMessages] = useState([])
  const [importPreview, setImportPreview] = useState('')
  const stripe = useStripe()
  const elements = useElements()

  const handleSignup = async event => {
    event.preventDefault()
    const errs = {}
    if (!stripe || !elements) {
      return
    }
    if (name.length == 0) {
      errs.name = 'Name is required'
    }
    if (!/^\S+@\S+\.\S+$/.test(email)) {
      errs.email = 'Invalid E-mail'
    }
    if (organization.length == 0) {
      errs.organization = 'Organization is required'
    }
    if (!/(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}/.test(password)) {
      errs.password = 'Password must include lowercase and uppercase letters, numbers, and be at least 8 characters long'
    }
    if (password != passwordConfirmation) {
      errs.confirmation = 'does not match password'
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

  const handleAddUsers = () => {

  }
  const handleImport = () => {

  }
  const handleDropAccepted = async files => {
    const uploads = await uploadFiles(files, '/on_guard/import_users')
    fetch(uploads[0].preview_url).then(response => response.text()).then(text => {
      setImportPreview(text)
    })

  }
  const handleDropRejected = () => {
    setFileMessages([{
          text: 'must be .csv',
          type: 'error'
        }])
  }

  const addUser = () => {
    const errs={}
    if (newUser.length == 0) {
      errs.newUser = 'Name is required'
    }
    if (!/^\S+@\S+\.\S+$/.test(newEmail)) {
      errs.newEmail = 'Provide a valid E-mail address'
    }
    const search = users.filter(user => {return user.email === newEmail})
    if (search.length > 0) {
      errs.newEmail = 'Duplicate E-mail'
    }
    if (Object.keys(errs).length > 0) {
      setErr(errs)
    } else {
      setUsers([...users, {user: newUser, email: newEmail}])
      setNewEmail('')
      setNewUser('')
      setErr({})
    }
  }

  switch (status) {
    case 'active':
      /**
       Add additional users, step 2
       */
      return (
        <Modal
          as="form"
          onSubmit={handleAddUsers}
          open
          size="large"
          label="Add Users"
          shouldCloseOnDocumentClick={false}
        >
          <Modal.Body>
            <FormFieldGroup layout="columns" rowSpacing="small" description="">
              <Grid.Col width="auto">
                <TextInput
                  renderLabel="Name"
                  value={newUser}
                  onChange={e => setNewUser(e.target.value)}
                  messages={err.newUser && [{type: 'error', text: err.newUser}]}
                />
              </Grid.Col>
              <Grid.Col width="auto">
                <TextInput
                  renderLabel="Email"
                  value={newEmail}
                  onChange={e => setNewEmail(e.target.value)}
                  messages={err.newEmail && [{type: 'error', text: err.newEmail}]}
                />
              </Grid.Col>
              <Grid.Col width="auto">
                <div style={{marginBottom: '10px'}}>&nbsp;</div>
                <Button onClick={addUser}>＋</Button>
              </Grid.Col>
              <Grid.Col width="auto" className="button-fill-vertical">
                {users.slice(-4).map(user => {
                  return (
                    <div key={user}>
                      {user.user} &lt;{user.email}&gt;
                    </div>
                  )
                })}
              </Grid.Col>
            </FormFieldGroup>
          </Modal.Body>
          <Modal.Footer>
            <Button>Skip</Button> &nbsp;
            <Button variant="primary" onClick={() => setStatus('import')}>Import</Button>&nbsp;
            <Button type="submit" variant="primary">
              Add Users
            </Button>
          </Modal.Footer>
        </Modal>
      )
    case 'import':
      /**
       * Import Users
       */
      return (
        <Modal
          as="form"
          onSubmit={handleImport}
          open
          size="small"
          label="Import Users"
          shouldCloseOnDocumentClick={false}
        >
          <Modal.Body>
            <FileDrop
              accept='.csv'
              allowMultiple
              enablePreview
              id="importFile"
              data-testid="input-file-drop"
              label={
                <Billboard
                  heading={'Upload File'}
                  hero={''}
                  message={
                    <Flex direction="column">
                        <Flex.Item>
                          {'File permitted: .csv'}
                        </Flex.Item>
                      <Flex.Item padding="small 0 0">
                        <Text size="small">
                          {'Drag and drop, or click to browse your computer'}
                        </Text>
                      </Flex.Item>
                    </Flex>
                  }
                /> }
              messages={fileMessages}
              onDropAccepted={files => handleDropAccepted(files)}
              onDropRejected={handleDropRejected}
            />
            <div dangerouslySetInnerHTML={{__html: importPreview}} />
          </Modal.Body>
          <Modal.Footer>
            <Button>Skip</Button> &nbsp;
            <Button variant="primary" onClick={() => setStatus('active')}>Manual Entry</Button>&nbsp;
            <Button type="submit" variant="primary">
              Add Users
            </Button>
          </Modal.Footer>
        </Modal>
      )
    default:
      /*
       Initial Sign Up form, step 1
       */
      return (
        <div>
          <div className="loading-spinner">
            <ClimbingBoxLoader
              size={20}
              color="#D7B236"
              loading={loading}
              css={`
                display: block;
                position: fixed;
                z-index: 10099;
                margin-left: -4em;
                margin-top: -3.5em;
                left: 50%;
                top: 50%;
              `}
            />
          </div>
          <Modal
            as="form"
            onSubmit={handleSignup}
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
                  messages={err.organization && [{type: 'error', text: err.organization}]}
                />

                <TextInput
                  renderLabel="Name"
                  value={name}
                  onChange={e => setName(e.target.value)}
                  messages={err.name && [{type: 'error', text: err.name}]}
                />
                <TextInput
                  renderLabel="E-mail"
                  value={email}
                  onChange={e => setEmail(e.target.value)}
                  messages={err.email && [{type: 'error', text: err.email}]}
                />
                <TextInput
                  renderLabel="Password"
                  value={password}
                  onChange={e => setPassword(e.target.value)}
                  type="password"
                  messages={err.password && [{type: 'error', text: err.password}]}
                />
                <TextInput
                  renderLabel="Password Confirmation"
                  value={passwordConfirmation}
                  onChange={e => setPasswordConfirmation(e.target.value)}
                  type="password"
                  messages={err.confirmation && [{type: 'error', text: err.confirmation}]}
                />
              </FormFieldGroup>
              <span className="cMIPy_bGBk">
                <span className="bNerA_bGBk bNerA_NmrE bNerA_dBtH bNerA_bBOa bNerA_buDT bNerA_DpxJ">
                  <span className="fCrpb_bGBk fCrpb_egrg">Payment Details</span>
                </span>
              </span>
              <div
                style={{
                  border: '0.0625rem solid #C7CDD1',
                  borderRadius: '0.25rem',
                  padding: '10px 20px'
                }}
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
