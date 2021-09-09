class BrokerCompanyNameSubstitutionsController < ApplicationController
  before_action :set_resource, only: %i[edit update destroy]

  def index
    @broker_company_name_substitutions = BrokerCompanyNameSubstitution.all.order(:before)
  end

  def new
    @broker_company_name_substitution = BrokerCompanyNameSubstitution.new(before: params[:before])
  end

  def edit
  end

  def create
    @broker_company_name_substitution = BrokerCompanyNameSubstitution.new(broker_company_name_substitution_params)

    if @broker_company_name_substitution.save
      redirect_to broker_company_name_substitutions_path,
                  notice: 'Broker company name substitution was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @broker_company_name_substitution.update(broker_company_name_substitution_params)
      redirect_to broker_company_name_substitutions_path,
                  notice: 'Broker company name substitution was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @broker_company_name_substitution.destroy
    redirect_to broker_company_name_substitutions_url,
                notice: 'Broker company name substitution was successfully destroyed.'
  end

  private

  def set_resource
    @broker_company_name_substitution = BrokerCompanyNameSubstitution.find(params[:id])
  end

  def broker_company_name_substitution_params
    params.require(:broker_company_name_substitution).permit(:before, :after)
  end
end
