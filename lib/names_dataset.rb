# frozen_string_literal: true

require "iso_country_codes"
require "json"
require "zip"
require_relative "names_dataset/version"

class NamesDataset
  class Error < StandardError; end

  attr_reader :first_names, :last_names

  FIRST_NAMES_ZIP_PATH = File.expand_path("../../data/first_names.zip", __FILE__)
  LAST_NAMES_ZIP_PATH = File.expand_path("../../data/last_names.zip",  __FILE__)

  def initialize(first_names_path: FIRST_NAMES_ZIP_PATH, last_names_path: LAST_NAMES_ZIP_PATH)
    @first_names = load_zipped_json(first_names_path)
    @last_names  = load_zipped_json(last_names_path)
  end

  def search(name)
    return empty_result if name.nil? || name.strip.empty?

    n = normalize(name)
    first_name_data = post_process(@first_names[n]) if @first_names.key?(n)
    last_name_data = post_process(@last_names[n]) if @last_names.key?(n)

    {
      first_name: first_name_data || empty_name_metadata,
      last_name: last_name_data || empty_name_metadata
    }
  end

  def get_country_codes(alpha_2: true)
    dataset = @first_names || @last_names
    country_codes = dataset.values.flat_map { |entry| entry["country"].keys }.uniq
    alpha_2 ? country_codes : country_codes.map { |code| IsoCountryCodes.find(code).name }.compact
  end

  def get_top_names(n: 10, gender: nil, country_alpha2: nil)
    raise ArgumentError, "n must be positive" if n <= 0

    dataset = @first_names
    raise Error, "No dataset loaded" if dataset.nil?

    ranks_per_country = Hash.new { |h, k| h[k] = Hash.new { |hh, kk| hh[kk] = [] } }

    dataset.each do |name, data|
      next unless matches_gender?(data, gender)

      data["rank"].each do |country, rank|
        next if country_alpha2 && country != country_alpha2

        gender_label = determine_gender(data["gender"])
        ranks_per_country[country][gender_label] << [name, rank]
      end
    end

    ranks_per_country.each do |country, genders|
      genders.each_key do |gender_label|
        genders[gender_label] = genders[gender_label].sort_by(&:last).take(n).map(&:first)
      end
    end

    ranks_per_country
  end

  def load_zipped_json(zip_path)
    return {} unless File.exist?(zip_path)

    content = nil
    Zip::File.open(zip_path) do |zip_file|
      entry = zip_file.first
      content = entry.get_input_stream.read if entry
    end
    content ? JSON.parse(content) : {}
  rescue StandardError => e
    warn "Failed to load or parse #{zip_path}: #{e.message}"
    {}
  end

  def normalize(str)
    str.strip.capitalize
  end

  def post_process(data)
    return nil unless data

    {
      "country" => map_country_codes(data["country"]),
      "gender" => map_gender(data["gender"]),
      "rank" => map_country_codes(data["rank"])
    }
  end

  def map_country_codes(data)
    data.transform_keys do |alpha2|
      begin
        IsoCountryCodes.find(alpha2).name
      rescue IsoCountryCodes::UnknownCodeError
        nil
      end
    end.compact
  end

  def map_gender(data)
    gender_map = { "M" => "Male", "F" => "Female" }
    data.transform_keys { |key| gender_map[key] }
  end

  def matches_gender?(data, gender)
    return true unless gender

    gender_key = gender.downcase.start_with?("m") ? "M" : "F"
    data["gender"].key?(gender_key)
  end

  def determine_gender(gender_data)
    return "N/A" if gender_data.empty?

    if gender_data.size == 1
      gender_data.keys.first
    else
      gender_data["M"] > gender_data["F"] ? "M" : "F"
    end
  end

  def empty_result
    { first_name: empty_name_metadata, last_name: empty_name_metadata }
  end

  def empty_name_metadata
    { "country" => {}, "gender" => {}, "rank" => {} }
  end
end
