# First and Last Names Dataset

`NamesDataset` is a Ruby library (ported from the python [philipperemy/name-dataset](https://github.com/philipperemy/name-dataset) library) that provides fast lookups and metadata for first and last names. Ever wondered if “Zoe” is more likely a name from the United Kingdom or how popular “White” is as a last name in the United States? This library helps you answer those questions.

`NamesDataset` can help you:
- Search for a first or last name and learn about:
- Probable country of origin
- Gender distribution (for first names)
- Rank/popularity
- Get lists of top names by country and gender.

Under the hood, `NamesDataset` loads an in-memory dataset (derived from a Facebook leak of 533M users) that’s roughly 3.2GB once loaded into memory. Once loaded, it’s quick to search but definitely requires some hardware overhead, so keep that in mind if you’re planning on deploying this to production.

## Requirements
- Ruby >= 2.7 (tested on 2.7, 3.0, 3.1, 3.2).
- Approximately 3.2GB of RAM available to load the full dataset.

## Installation

Add the gem to your Gemfile and run bundle.

```ruby
gem "names_dataset"
```

Then require the library and initialize it in your application.

```ruby
require "names_dataset"

# The library takes time to initialize because the database is massive.
# A tip is to include its initialization in your app's startup process.
nd = NamesDataset.new
```

## Usage

`NamesDataset` provides methods to query the dataset for information about first and last names. Here are some examples:

```ruby
nd = NamesDataset.new

p nd.search("Philippe")
# => {
#      :first_name => {
#        :country => { "France" => 0.63, "Belgium" => 0.12, ... },
#        :gender  => { "Male" => 0.99, "Female" => 0.01 },
#        :rank    => { "France" => 73, "Belgium" => 291, ... }
#      },
#      :last_name => {
#        :country => {},
#        :gender  => {},
#        :rank    => {}
#      }
#    }

p nd.search("Zoe")
# => {
#      :first_name => {
#        :country => { "United Kingdom" => 0.52, "United States" => 0.23, ... },
#        :gender  => { "Female" => 0.98, "Male" => 0.02 },
#        :rank    => { "United Kingdom" => 140, "United States" => 315, ... }
#      },
#      :last_name => { ... }
#    }
```

The result is a Ruby Hash with the following structure:
- `:first_name`: Includes `:country`, `:gender`, `:rank`
- `:last_name`: Includes `:country`, `:gender` (generally empty for last names), and `:rank`

### Memory Usage Disclaimer

Because the library pre-loads the entire 3.2GB dataset into memory, you’ll need sufficient RAM to avoid NoMemoryError. If you only need a subset of the data or if memory is a major concern, consider alternative approaches (e.g., a streaming or database-based solution). But if you can spare the memory, NamesDataset is fast for repeated lookups once it’s loaded.

### Top Names

Similar to the Python library, you can fetch the most popular names by country or gender:

```ruby
p nd.get_top_names(n: 10, gender: "Male", country_alpha2: "US")
# => {
#      "US" => {
#        "M" => ["Jose", "David", "Michael", "John", "Juan", ... ]
#      }
#    }

p nd.get_top_names(n: 5, country_alpha2: "ES")
# => {
#      "ES" => {
#        "M" => ["Jose", "Antonio", "Juan", "Manuel", "David"],
#        "F" => ["Maria", "Ana", "Carmen", "Laura", "Isabel"]
#      }
#    }
```

### Other Helpers

```ruby
p nd.get_country_codes(alpha_2: true)
# => ["AE", "AF", "AL", "AO", "AR", "AT", ... ]

nd.first_names
# => A Hash of first names mapped to their attributes (country, gender, rank, etc).

nd.last_names
# => A Hash of last names mapped to their attributes (country, rank, etc).
```

## Full Dataset

For offline or alternative usage, a link to the raw dataset can be found in the [original Python library](https://github.com/philipperemy/name-dataset/blob/6ae42a6a84a7b6460baa2cbd440f0cdf9fe81752/README.md#full-dataset).

## Contributing

We welcome contributions! Feel free to open an issue or submit a pull request on GitHub.

## License

This library is subject to the same considerations as the Python version:
- The dataset is generated from a large-scale Facebook leak (533M accounts).
- Basic lists of names are [typically not copyrightable](https://github.com/philipperemy/name-dataset/blob/6ae42a6a84a7b6460baa2cbd440f0cdf9fe81752/README.md#license), but please consult a lawyer if you have specific legal concerns.
- You can find the full license from the original python library in [that project](https://github.com/philipperemy/name-dataset/blob/6ae42a6a84a7b6460baa2cbd440f0cdf9fe81752/LICENSE).
- You can find the full license for this Ruby port in the [LICENSE](LICENSE) file at the root of this repository.

Thanks for checking out `names_dataset`! If this library helps you ship something neat, I’d love to know about it, feel free to open a Pull Request or Issue :heart:
