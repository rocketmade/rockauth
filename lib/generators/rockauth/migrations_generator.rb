module Rockauth
  class MigrationsGenerator < Rails::Generators::Base
    def install_migrations
      Dir[File.expand_path("../../../../db/migrate/*.rb", __FILE__)].each do |file|
        copy_file file, "db/migrate/#{File.basename(file)}"
      end
    end
  end
end
