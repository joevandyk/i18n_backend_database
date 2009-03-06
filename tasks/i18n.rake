def load_default_locales(path_to_file=nil)
  path_to_file ||= File.join(File.dirname(__FILE__), "../data", "locales.yml")
  data = YAML::load(IO.read(path_to_file))
  data.each do |code, y|
    Locale.create({:code => code, :name => y["name"]})
  end
end

namespace :i18n do
  desc 'Clear cache'
  task :clear_cache => :environment do
    I18n.backend.cache_store.clear
  end

  desc 'Install admin panel assets'
  task :install_admin_assets => :environment do
    images_dir     = Rails.root + '/public/images/'
    javascripts_dir = Rails.root + '/public/javascripts/'
    images  = Dir[File.join(File.dirname(__FILE__), '..') + '/lib/public/images/*.*']
    scripts = Dir[File.join(File.dirname(__FILE__), '..') + '/lib/public/javascripts/*.*']
    FileUtils.cp(images,  images_dir)
    FileUtils.cp(scripts, javascripts_dir)
  end

  namespace :populate do
    desc 'Populate the locales and translations tables from all Rails Locale YAML files. Can set LOCALE_YAML_FILES to comma separated list of files to overide'
    task :from_rails => :environment do
      yaml_files = ENV['LOCALE_YAML_FILES'] ? ENV['LOCALE_YAML_FILES'].split(',') : I18n.load_path
      yaml_files.each do |file|
        I18nUtil.load_from_yml file
      end
    end

    desc 'Populate the translation tables from translation calls within the application. This only works on basic text translations'
    task :from_application => :environment do
      I18nUtil.seed_application_translations
    end

    desc 'Populate default locales'
    task :load_default_locales => :environment do
      load_default_locales(ENV['LOCALE_FILE'])
    end
  end
end
