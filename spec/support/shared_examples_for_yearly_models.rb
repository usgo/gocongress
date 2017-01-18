RSpec.shared_examples "a yearly model" do
  describe "#yr" do
    it "returns records with the given year" do
      model_class = subject.class
      expect(model_class).to respond_to :yr
      y = [2011, 2012].sample
      expect(model_class).to receive(:where).with(year: y)
      model_class.yr(y)
    end
  end
end
