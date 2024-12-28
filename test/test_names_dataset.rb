# frozen_string_literal: true

require "json"
require "names_dataset"
require "test_helper"
require "zip"

class TestNamesDataset < Minitest::Test
  def setup
    # Create sample data for first names and last names
    @first_names_data = {
      "John" => {
        "country" => {"US" => 90},
        "gender" => {"M" => 1.0},
        "rank" => {"US" => 1}
      },
      "Jane" => {
        "country" => {"US" => 10},
        "gender" => {"F" => 1.0},
        "rank" => {"US" => 2}
      }
    }
    @last_names_data = {
      "Doe" => {
        "country" => {"US" => 100},
        "gender" => {},
        "rank" => {"US" => 1}
      }
    }

    # Mock zip files
    @first_names_zip = create_mock_zip(@first_names_data)
    @last_names_zip = create_mock_zip(@last_names_data)

    # Initialize the dataset
    @names_dataset = NamesDataset.new(
      first_names_path: @first_names_zip.path,
      last_names_path: @last_names_zip.path
    )
  end

  def teardown
    @first_names_zip.unlink
    @last_names_zip.unlink
  end

  def test_initialization
    refute_nil @names_dataset.first_names
    refute_nil @names_dataset.last_names
    assert_equal @first_names_data, @names_dataset.first_names
    assert_equal @last_names_data, @names_dataset.last_names
  end

  def test_search
    result = @names_dataset.search("John")
    assert_equal "United States of America", result[:first_name]["country"].keys.first
    assert_equal "Male", result[:first_name]["gender"].keys.first

    result = @names_dataset.search("Unknown")
    assert_empty result[:first_name]["country"]
    assert_empty result[:last_name]["country"]
  end

  def test_get_country_codes
    codes = @names_dataset.get_country_codes
    assert_includes codes, "US"

    country_names = @names_dataset.get_country_codes(alpha_2: false)
    assert_includes country_names, "United States of America"
  end

  def test_get_top_names
    top_names = @names_dataset.get_top_names(n: 1, gender: "Male")
    assert_includes top_names["US"]["M"], "John"

    top_names_female = @names_dataset.get_top_names(n: 1, gender: "Female")
    assert_includes top_names_female["US"]["F"], "Jane"
  end

  def test_normalize
    assert_equal "John", @names_dataset.normalize("  john ")
    assert_equal "Jane", @names_dataset.normalize("JANE")
  end

  private

  # Helper to create a mock zip file with the given data
  def create_mock_zip(data)
    require "tempfile"
    tempfile = Tempfile.new(["names", ".zip"])

    Zip::File.open(tempfile.path, Zip::File::CREATE) do |zipfile|
      zipfile.get_output_stream("names.json") { |f| f.write(data.to_json) }
    end

    tempfile
  end
end
