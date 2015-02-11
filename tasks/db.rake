require 'fias'
require 'ruby-progressbar'
require 'sequel'

namespace :fias do
  desc 'Create FIAS tables (PREFIX, FIAS_PATH to dbfs, DATABASE_URL and TABLES)'
  task :create_tables do
    within_connection do |tables|
      tables.create
      puts "#{tables.files.keys.join(', ')} created."
    end
  end

  desc 'Import FIAS data (PREFIX, FIAS_PATH to dbfs, DATABASE_URL and TABLES)'
  task :import do
    within_connection do |tables|
      tables.copy.each do |table|
        puts "Encoding #{table.table_name}..."
        bar = ProgressBar.create(
          total: table.dbf.record_count,
          format: '%a |%B| [%E] (%c/%C) %p%%'
        )

        table.encode { bar.increment }
        table.copy
      end
    end
  end

  desc 'Build active elements tree'
  task :build do
    require 'benchmark'
    require 'active_support/core_ext/enumerable'

    db = Sequel.connect(ENV['DATABASE_URL'])
    puts Benchmark.measure {
      raw =
        db[:fias_address_objects]
          .where(livestatus: 1)
          .select_map([:id, :aoguid, :parentguid])

      by_aoguid = raw.index_by { |r| r[1] }

      bar = ProgressBar.create(
        total: raw.size,
        format: '%a |%B| [%E] (%c/%C) %p%%'
      )

      tree = raw.map do |row|
        bar.increment

        if row[2]
          parent_id = by_aoguid[row[2]]
          parent_id = parent_id[0] if parent_id
        end

        [row[0], parent_id]
      end

      by_parent_id = tree.group_by { |row| row[1] }
    }
  end

  private

  def connect_db
    if ENV['DATABASE_URL'].blank?
      fail 'Specify DATABASE_URL (eg. postgres://localhost/fias)'
    end

    Sequel.connect(ENV['DATABASE_URL'])
  end

  def within_connection(&block)
    db = Sequel.connect(ENV['DATABASE_URL'])
    fias_path = ENV['FIAS_PATH'] || 'tmp/fias'
    only = *ENV['TABLES'].to_s.split(',')
    files = Fias::Import::Dbf.new(fias_path).only(*only)
    tables = Fias::Import::Tables.new(db, files)

    diff = only - files.keys.map(&:to_s)
    puts "WARNING: Missing DBF files for: #{diff.join(', ')}" if diff.any?

    yield(tables)
  end
end