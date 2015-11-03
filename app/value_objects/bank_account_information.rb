class BankAccountInformation
  def initialize(iban, bic, owner, bank)
    @iban = iban
    @bic = bic
    @owner = owner
    @bank = bank
  end

  def eql?(other)
    to_s == other.to_s
  end

  def complete?
    @iban.present? &&
    @bic.present? &&
    @owner.present? &&
    @bank.present?
  end

  def to_s
    "#{@owner}, IBAN: #{@iban}, BIC: #{@bic} (#{@bank})"
  end
end
