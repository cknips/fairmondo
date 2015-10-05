require_relative '../test_helper'
include PunditMatcher

describe RefundPolicy do
  let(:refund) { FactoryGirl.create :refund }
  subject { RefundPolicy.new(user, refund) }

  def setup
    fake_api = stub(fastbill_refund_fee: nil, fastbill_refund_fair: nil)
    FastbillAPI.stubs(:new).returns(fake_api)
  end

  describe 'for a visitor' do
    let(:user) { nil }
    it 'should deny refund create for visitors' do
      subject.must_deny(:create)
      subject.must_deny(:new)
    end
  end

  describe 'for a logged in user' do
    describe 'who owns business_transaction' do
      let(:user) { refund.business_transaction_seller }

      describe 'that is sold' do
        describe 'and is not refunded' do
          let(:refund) do
            Refund.new business_transaction:
                         FactoryGirl.create(:business_transaction, :old)
          end

          it { subject.must_permit(:create) }
          it { subject.must_permit(:new) }
        end

        describe 'and is refunded' do
          it { subject.must_deny(:create) }
          it { subject.must_deny(:new) }
        end
      end
    end

    describe 'who does not own business_transaction' do
      let(:user) { FactoryGirl.create :user }
      it { subject.must_deny(:create) }
      it { subject.must_deny(:new) }
    end
  end
end
