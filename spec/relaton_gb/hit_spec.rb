RSpec.describe RelatonGb::Hit do
  subject { RelatonGb::Hit.new pid: "1234", title: "Title", scrapper: nil }

  it "returns string" do
    expect(subject.to_s).to eq(
      "<RelatonGb::Hit:#{format('%#.14x', subject.object_id << 1)} @fullIdentifier=\"\" @title=\"Title\">",
    )
  end
end
