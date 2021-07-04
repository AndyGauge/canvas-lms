module OnGuard
  class BillingPlansController < ApplicationController
    before_action :load_billing_plan, only: [:show]
    skip_before_action :verify_authenticity_token


    def show
      respond_to do |format|
        format.html {
          render layout:'bare'
        }
        format.json {
          render json: @billing_plan.as_json(only: [:id, :name, :display_price, :description])
        }
      end
    end

    private
    def load_billing_plan
      @billing_plan=OnGuard::BillingPlan.find(params[:id])
    end
  end
end
