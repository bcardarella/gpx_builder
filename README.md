# Mass Bay, Hingham Bay, and Salem Bay racing mark GPX builder


### Requirements

1. [Elixir](https://elixir-lang.org)
2. SAXCount part of the [Xerces Apache](https://xerces.apache.org) library

This script is written in Elixir. To run:

```cmd
> elixir generator.exs
```

The generated GPX files will be in `output/`

You can use these GPX files to populate waypoints in your Chartplotter.

The input data was scraped from the [Mass Bay 2019 Yearbook](http://www.massbaysailing.org/page/news/yearbook)

This was hacked together in a day. Code quality reflects that, but it works.