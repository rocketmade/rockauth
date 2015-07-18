require 'spec_helper'


module Rockauth
  describe ProviderUserInformation, social_auth: true do
    describe ".for_provider" do
      it "returns an instance for the given provider" do
        expect(described_class.for_provider(:facebook,    'foo', nil)).to be_an_instance_of(ProviderUserInformation::Facebook)
        expect(described_class.for_provider(:twitter,     'foo', nil)).to be_an_instance_of(ProviderUserInformation::Twitter)
        expect(described_class.for_provider(:google_plus, 'foo', nil)).to be_an_instance_of(ProviderUserInformation::GooglePlus)
        expect(described_class.for_provider(:instagram,   'foo', nil)).to be_an_instance_of(ProviderUserInformation::Instagram)
      end
    end

    [ProviderUserInformation::Facebook, ProviderUserInformation::Twitter, ProviderUserInformation::GooglePlus, ProviderUserInformation::Instagram].each do |klass|
      describe klass do
        it "conforms to the interface" do
          %i(user_id get_user picture_url).each do |meth|
            expect(described_class.new('foo', 'bar')).to respond_to(meth)
          end
        end

        describe ".valid?" do
          it "considers the valid if a provider user id can be found" do
            instance = described_class.new
            allow(instance).to receive(:user_id).and_return 'foo'
            expect(instance.valid?).to eq true
          end
          it "considers the record invalid if no provider user id can be found" do
            instance = described_class.new
            allow(instance).to receive(:user_id).and_return nil
            expect(instance.valid?).to eq false
          end
        end

      end
    end
  end
end
