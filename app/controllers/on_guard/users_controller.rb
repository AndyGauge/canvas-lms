module OnGuard
  class UsersController < ApplicationController

    include Api::V1::Attachment
    include Api::V1::Account

    before_action :require_user, :only => [ 'index', 'import_response' ]
    before_action :require_registered_user, :only => 'index'
    before_action :load_organization, :only => [ 'index', 'import_response' ]

    def index
      @account = @organization.account
      js_env({
                 COURSE_ROLES: Role.course_role_data_for_account(@account, @current_user)
             })
      js_bundle :on_guard_users
      css_bundle :addpeople
      @page_title = @account.name
      add_crumb '', '?' # the text for this will be set by javascript
      js_env({
                 ROOT_ACCOUNT_NAME: @account.root_account.name, # used in AddPeopleApp modal
                 ACCOUNT_ID: @account.id,
                 ROOT_ACCOUNT_ID: @account.root_account.id,
                 customized_login_handle_name: @account.root_account.customized_login_handle_name,
                 delegated_authentication: @account.root_account.delegated_authentication?,
                 SHOW_SIS_ID_IN_NEW_USER_FORM: @account.root_account.allow_sis_import && @account.root_account.grants_right?(@current_user, session, :manage_sis),
                 LINK_CODE: register_url(join: @organization.link_code),
                 PERMISSIONS: {
                     can_read_course_list: false,
                     can_read_roster: supervisor?,
                     can_create_courses: false,
                     can_create_enrollments: false,
                     can_create_users: supervisor?,
                     analytics: @account.service_enabled?(:analytics),
                     can_masquerade: false,
                     can_message_users: false,
                     can_edit_users: supervisor?,
                     can_manage_groups: false,
                     can_manage_admin_users: false
                 }
             })
      render html: '', layout: true
    end

    def create
      org=OnGuard::Organization.find_by_link_code(params[:user][:self_enrollment_code])
      errors = OnGuard::RegistrationValidator.new(params[:user], params[:pseudonym], org).errors
      errors << {message: "Invalid Link Code", input_name: "user[self_enrollment_code]"} unless org

      render json: {error: errors}.to_json, status: 400 and return unless errors.empty?
      org.register_user(params[:user][:name], params[:pseudonym])

    end

    def new
      @body_classes << ['onguard_background']
      return redirect_to(root_url) if @current_user
      @join_code = params[:join]
      if org=OnGuard::Organization.find_by_link_code(@join_code)
        @trusted = org.trusted?
      else
        @trusted = true
      end
      run_login_hooks
      js_env({
                 :ACCOUNT => account_json(@domain_root_account, nil, session, ['registration_settings']),
                 :PASSWORD_POLICY => @domain_root_account.password_policy,
                 :TRUST => @trusted
             })
      render :layout => 'bare'
    end

    def import_users
     user = User.find(params[:id])

      api_attachment_preflight(
          user, request
      )
    end

    def import_response
      render plain: OnGuard::Import.new(User.find(params[:id]).attachments.not_deleted.find_by_id(params[:response_id]).open, @organization).to_json
    end

    def import_complete
      @current_user.on_guard_organization.delay.invite_users(params["_json"])
      render json: {status: 'ok'}
    end

    private
    def load_organization
      @organization = @current_user.on_guard_organization
    end

    def supervisor?
      !!@current_user.on_guard_supervisor
    end

  end
end
