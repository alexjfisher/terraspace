describe Terraspace::Compiler::Expander::S3 do
  let(:state) { described_class.new(mod) }
  let(:props) do
    {
      bucket:         "my-bucket",
      key:            ":env/:build_dir/terraform.tfstate", # variable notation expanded by terraspace
      region:         ENV["AWS_REGION"],
      encrypt:        true,
      dynamodb_table: "terraform_locks"
    }
  end
  let(:mod) do
    mod = double(:mod).as_null_object
    allow(mod).to receive(:build_dir).and_return("stacks/core")
    mod
  end

  context "default path" do
    it "expand" do
      result = state.expand(props)
      result.delete(:region) # may be different depending on ENV['REGION']
      expect(result).to eq({
        bucket: "my-bucket",
        key: "dev/stacks/core/terraform.tfstate",
        encrypt: true,
        dynamodb_table: "terraform_locks"
      })
    end
  end
end
