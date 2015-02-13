# FIAS

[![Build Status](https://travis-ci.org/evilmartians/fias.svg)](http://travis-ci.org/evilmartians/fias)
[![Code Climate](https://codeclimate.com/github/evilmartians/fias/badges/gpa.svg)](https://codeclimate.
com/github/evilmartians/fias)
[![Test Coverage](https://codeclimate.com/github/evilmartians/fias/badges/coverage.svg)](https://codeclimate.com/github/evilmartians/fias)

Ruby wrapper for the Russian [ФИАС](http://fias.nalog.ru) database.

Designed for use with Ruby on Rails and a PostgreSQL backend.

<a href="https://evilmartians.com/?utm_source=fias-gem">
<img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" width="236" height="54">
</a>

Think twice before you decide to use standalone copy of FIAS database in your project. [КЛАДР в облаке](https://kladr-api.ru/) could also be a solution.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fias'
```

And then execute:

    $ bundle

Or install it yourself:

    $ gem install fias

## Import into SQL

    $ mkdir -p tmp/fias && cd tmp/fias
    $ bundle exec rake fias:download | xargs wget
    $ unrar e fias_dbf.rar
    $ bundle exec rake fias:create_tables fias:import DATABASE_URL=postgres://localhost/fias

The rake task accepts options through ENV vars:

* `TABLES` to specify a comma-separated list of a tables to import/create. See `Fias::Import::Dbf::TABLES` for the list of key names. Use `houses` as an alias for HOUSE* tables and `nordocs` for NORDOC* tables. In most cases you'll need `address_objects` table only.
* `PREFIX` for the database tables prefix ('fias_' by default).
* `PATH` to specify DBF files location ('tmp/fias' by default).
* `DATABASE_URL` to set database credentials (needed explicitly even project is on Rails).

Gem uses `COPY FROM STDIN BINARY` to import data. Works with PostgreSQL only.

## Notes about FIAS

1. FIAS address objects table contains a lot of fields which are not useful in most cases (tax office id, legal document id etc).
2. Address objects table contains lot of historical records (more than 50% in fact) which are not useful in most cases.
3. Every record in address object table could have multiple parents. For example, Nevsky prospekt in Saint Petersburg has two parents: Saint Petersburg (active) and Leningrad (historical name of the city, inactive). Most hierarchy libraries accepts just one parent for a record.
4. Using UUID type field as a primary key as it used in FIAS is not a good idea if you want to use ancestry or closure_tree gems to navigate through record tree.
5. Typical SQL production server settings are optimized for reading, so import on production could take dramatically long time.

## Notes on initial import workflow

1. Use raw FIAS tables just as a temporary data source for creating/updating primary address objects table in your app.
2. The only requirement is to keep AOGUID, PARENTGUID and AOID fields in target table. You will need it for updating.
3. Keep your addressing object table immutable. This will give you an ability to work with huge amount of addressing data locally. Send the result to production as an SQL dump.
4. FIAS contains some duplicates. Duplicates are records which has different UUIDs but equal names, abbrevations and nesting level. You should decide what to do with it: completely remove or just mark as hidden.
5. [closure_tree](https://github.com/mceachen/closure_tree) works great as hierarchy backend. Use [pg_closure_tree_rebuild](https://github.com/gzigzigzeo/pg_closure_tree_rebuild) to rebuild hierarchy table from scratch.

[See example](examples/create.rb)

## Toponyms

Every FIAS address object has two fields: `formalname` holding toponym (the name of a geographical object) and `shortname` holding it's type (street, city, etc). FIAS contains the list of all available `shortname` values and corresponding long forms in `address_object_types` table (SOCRBASE.DBF).

### Canonical forms

In real life people use a lot of type name variations. For example, 'проспект' can be written as 'пр' or 'пр-кт'.

You can convert any variation to a canonical form:

```ruby
Fias::Name::Canonical.canonical('поселок')
# => [
#  'поселок', # FIAS canonical full name
#  'п',       # FIAS canonical short name (as in address_objects table)
#  'п.',      # Short name with dot if needed
#  'пос',     # Alias
#  'посёлок'  # Alias
# ]
```

See [fias.rb](lib/fias.rb) for a settings.

### Append type to toponym

Use `Fias::Name::Append` to build toponym names in conformity with the rules of grammar:

```ruby
Fias::Name::Append.append('Санкт-Петербург', 'г')
# => ['г. Санкт-Петербург', 'город Санкт-Петербург']

Fias::Name::Append.append('Невский', 'пр')
# => ['Невский пр-кт', 'Невский проспект']

Fias::Name::Append.append('Чечня', 'республика')
# => ['Респ. Чечня', 'Республика Чечня']

Fias::Name::Append.append('Чеченская', 'республика')
# => ['Чеченская Респ.', 'Чеченская Республика']
```

You can pass any form of type name: full, short, an alias, with or without dot.

### Extract toponym

Sometimes you will need to extract toponym and it's type from a plain string:

```ruby
Fias::Name::Extract.extract('Город Санкт-Петербург')
# => ['Санкт-Петербург', 'город', 'г', 'г.']

Fias::Name::Extract.extract('ул. Казачий Вал')
# => ['Казачий Вал', 'улица', 'ул', 'ул.']
```

## Contributors

* Victor Sokolov (@gzigzigzeo)
* Vlad Bokov (@razum2um)

Special thanks to @gazay, @kirs

## Contributing

1. Fork it ( https://github.com/evilmartians/fias/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


## License

The MIT License
