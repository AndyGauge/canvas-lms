/*
 * Copyright (C) 2017 - present Instructure, Inc.
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

import React from 'react'
import {func, string, element} from 'prop-types'
import axios from 'axios'
import {Billboard} from '@instructure/ui-billboard'
import {Button} from '@instructure/ui-buttons'
import {Checkbox, TextInput} from '@instructure/ui-forms'
import {FileDrop} from '@instructure/ui-forms'
import {Flex} from '@instructure/ui-layout'
import {IconCheckMarkSolid} from '@instructure/ui-icons'
import Modal from '../../shared/components/InstuiModal'
import {ScreenReaderContent} from '@instructure/ui-a11y'
import {Spinner} from '@instructure/ui-elements'
import {Table} from '@instructure/ui-elements'
import {Text} from '@instructure/ui-elements'
import {uploadFiles} from '../../shared/upload_file'
import {View} from '@instructure/ui-layout'

export default class ImportUserModal extends React.Component {
  static propTypes = {
    // whatever you pass as the child, when clicked, will open the dialog
    children: element.isRequired,
    url: string.isRequired,
    afterSave: func.isRequired
  }
  constructor(props) {
    super(props);
    this.state = {
      fileMessages: [],
      open: false,
      users: [],
      loading: false
    }
  }

  handleDropAccepted = async (files) => {
    this.setState({loading:true})
    const uploads = await uploadFiles(files, this.props.url)
    uploads.map(upload => {
      fetch(this.props.url_response + upload.id, {
        headers: {
          'Content-Type': 'application/json'
        }
      })
        .then(response => response.json())
        .then(users => {
          users.map(user => {user.include=!(user.duplicate || user.blocked)})
          this.setState({users, loading:false}, () => this.sortBy('excluded'))
        })
    })
  }

  handleDropRejected = () => {
    this.setState({fileMessages: [
      {
        text: 'must be .csv',
        type: 'error'
      }
    ]})
  }

  handleAddUsers = () => {
    this.setState({loading:true})
    axios({url: this.props.url_complete, method: 'POST', data: this.state.users.filter(user => user.include)}).then(
      this.setState({open:false, users:[], loading:false})
    )
  }

  sortBy = (by) => {
    let users = [...this.state.users]
    switch(by) {
      case 'name':
        users.sort((a,b) => (a.name > b.name) ? 1 : -1)
        break;
      case 'email':
        users.sort((a,b) => (a.email > b.email) ? 1 : -1)
        break;
      case 'excluded':
        users.sort((a,b) => (a.duplicate > b.duplicate) ? 1 : -1)
        users.sort((a,b) => (a.blocked > b.blocked) ? 1 : -1)
        break;
    }
    this.setState({users})

  }

  check = (idx) => {
    let users = [...this.state.users]
    users[idx].include = !users[idx].include
    this.setState({users})
  }

  render = () => (
        <span>
      <Modal
        as="form"
        onSubmit={this.handleAddUsers}
        open={this.state.open}
        size="large"
        label="Import Users"
        shouldCloseOnDocumentClick={false}
        onDismiss={() => this.setState({open: false})}
      >
        <Modal.Body>
          <FileDrop
            accept=".csv"
            allowMultiple
            enablePreview
            id="importFile"
            data-testid="input-file-drop"
            label={
              <Billboard
                heading="Upload File"
                message={
                  <Flex direction="column">
                    <Flex.Item>File permitted: .csv</Flex.Item>
                    <Flex.Item padding="small 0 0">
                      <Text size="small">Drag and drop, or click to browse your computer</Text>
                    </Flex.Item>
                  </Flex>
                }
              />
            }
            messages={this.state.fileMessages}
            onDropAccepted={files => this.handleDropAccepted(files)}
            onDropRejected={this.handleDropRejected}
          />
          {this.state.loading ? (
          <View display="block" textAlign="center" padding="medium">
            <Spinner size="medium" renderTitle='Loading...' />
          </View>
          ) : (
          <Table
            margin="small 0"
            caption={<ScreenReaderContent>Users</ScreenReaderContent>}
          >
            <thead>
              <tr>
                <th scope={"col"}>
                  Import
                </th>
                <th scope="col">
                  <Button
                    variant="link"
                    onClick={() => this.sortBy('name')}
                    theme={{fontWeight: '700', mediumPadding: '0', mediumHeight: '1.5rem'}}>Name</Button>
                </th>
                <th scope="col">
                  <Button
                    variant="link"
                    onClick={() => this.sortBy('email')}
                    theme={{fontWeight: '700', mediumPadding: '0', mediumHeight: '1.5rem'}}>Email</Button>
                </th>
                <th scope={'col'} style={{textAlign: 'center'}}>
                  Duplicate
                </th>
                <th scope={'col'} style={{textAlign: 'center'}}>
                  Blocked
                </th>
              </tr>
            </thead>
            <tbody>
              {this.state.users.map((user, idx) =>
                <tr key={'import' + idx} style={user.include ? {} : {color: '#888'}}>
                  <td>
                    <div style={{width: 15, float: "left"}}>&nbsp;</div>
                    <div style={{width: '*'}}>
                      <Checkbox key={'importcheck' + idx} label={''} checked={user.include} value={user.include}
                                onChange={() => this.check(idx)}/>
                    </div>
                  </td>
                  <td>{user.name}</td>
                  <td>{user.email}</td>
                  <td style={{textAlign: 'center'}}>{user.duplicate ? <IconCheckMarkSolid/> : ''}</td>
                  <td style={{textAlign: 'center'}}>{user.blocked ? <IconCheckMarkSolid/> : ''}</td>
                </tr>
              )}

            </tbody>
          </Table>
          )}

        </Modal.Body>
        <Modal.Footer>
          <Button href={'http://on-guard.org/import-help'} target={'_blank'}>Help</Button>
          &nbsp;&nbsp;
          <Button onClick={() => this.setState({open: false})}>Cancel</Button>
          &nbsp;&nbsp;
          <Button type="submit" variant="primary">
            Add Users
          </Button>
        </Modal.Footer>
      </Modal>
          {React.Children.map(this.props.children, child =>
            // when you click whatever is the child element to this, open the modal
            React.cloneElement(child, {
              onClick: (...args) => {
                if (child.props.onClick) child.props.onClick(...args)
                this.setState({open: true})
              }
            })
          )}
    </span>
      )

}
