class TransactionsController < ApplicationController
  before_action :set_transaction, only: %i[ show edit update destroy ]

  # GET /transactions or /transactions.json
  def index
    @transactions = Transaction.order(created_at: :desc)
    @input_text = ""
  end

  # GET /transactions/1 or /transactions/1.json
  def show
  end

  # GET /transactions/new
  def new
    @transaction = Transaction.new
  end

  # GET /transactions/1/edit
  def edit
  end

  def report
    @grouped = Transaction.order(created_at: :desc).group_by(&:category)
  end


  # POST /transactions or /transactions.json
  def create
    parsed = TransactionParser.call(text: params[:input_text])

    @transaction = Transaction.new(
      description: params[:input_text],
      amount: parsed["amount"],
      category: parsed["category"]
    )

    if @transaction.save
      @transactions = Transaction.order(created_at: :desc)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to transactions_path, notice: "Сохранено" }
      end
    else
      render :index, alert: "Ошибка сохранения"
    end
  end


  # PATCH/PUT /transactions/1 or /transactions/1.json
  def update
    respond_to do |format|
      if @transaction.update(transaction_params)
        format.html { redirect_to @transaction, notice: "Transaction was successfully updated." }
        format.json { render :show, status: :ok, location: @transaction }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transactions/1 or /transactions/1.json
  def destroy
    @transaction.destroy!

    respond_to do |format|
      format.html { redirect_to transactions_path, status: :see_other, notice: "Transaction was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transaction
      @transaction = Transaction.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def transaction_params
      params.expect(transaction: [ :description, :amount, :category ])
    end
end
