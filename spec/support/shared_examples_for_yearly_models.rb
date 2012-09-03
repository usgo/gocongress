shared_examples "a yearly model" do
  describe "#yr" do
    it "returns records with the given year" do
      model_class = subject.class
      model_class.should respond_to :yr
      y = [2011, 2012].sample
      model_class.should_receive(:where).with(year: y)
      model_class.yr(y)
    end
  end
end
