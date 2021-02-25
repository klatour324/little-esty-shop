class Admin::MerchantsController < ApplicationController
  def index
    @merchants = Merchant.all
  end

  def show
    @merchant = Merchant.find(params[:id])
  end

  def edit
    @merchant = Merchant.find(params[:id])
  end

  def update
    @merchant = Merchant.update(merchant_params)
    if params[:status]
      redirect_to admin_merchants_path
    else
      redirect_to admin_merchant_path(@merchant)
    end
  end

  private
  def merchant_params
    params.permit(:name, :status)
  end
end