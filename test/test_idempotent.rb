require File.expand_path('../helper.rb', __FILE__)

describe 'a second auto_upgrade!' do

  # Starts from an empty database and only the models in models.rb, so that whatever the rest of
  # the suite has defined and left behind cannot be mistaken for a change of its own.
  before do
    ActiveRecord::Base.descendants.each { |klass|
      Object.send(:remove_const, klass.to_s) if Object.const_defined?(klass.name.to_s) && klass.to_s != "ActiveRecord::SchemaMigration"
    }
    conn.disable_referential_integrity do
      conn.tables.each { |table| silence_stream(STDERR) { conn.drop_table(table, :if_exists => true, :force => :cascade) } }
    end
    load File.expand_path('../models.rb', __FILE__)
  end

  it 'has nothing left to do' do
    ActiveRecord::Base.auto_upgrade!
    refute_empty conn.tables
    assert_match(/Creating Table/, ActiveRecord::Base.queries)

    ActiveRecord::Base.auto_upgrade!
    refute_match(/\[MiniRecord\]/, ActiveRecord::Base.queries)
  end

  it 'has nothing to report in a dry run either' do
    ActiveRecord::Base.auto_upgrade!

    ActiveRecord::Base.auto_upgrade_dry
    refute_match(/\[MiniRecord\]/, ActiveRecord::Base.queries)
  end
end
