require 'chef/knife'
require 'chef/knife/core/node_presenter'

module ZephirWorks
  class Knife
    class EnvironmentExportAll < Chef::Knife

      deps do
        require 'chef/node'
        require 'chef/json_compat'
      end

      banner "knife environment export all (options)"

      def run
        config[:format] = "json"
        ui.use_presenter Chef::Knife::Core::NodePresenter

        print "Exporting"
        environments = list

        environments.each do |environment_name|
          export(environment_name)
          print "."
        end
        puts "\n"
      end

    protected
      def list
        Chef::Environment.list.keys
      end

      def export(environment_name)
        environment = Chef::Environment.load(environment_name)

        result = {}
        result["name"] = environment.name
        result["description"] = environment.description
        result["json_class"] = environment.class.name
        result["default_attributes"] = sort_hash(environment.default_attributes)
        result["override_attributes"] = sort_hash(environment.override_attributes)
        result["chef_type"] = "environment"

        json = presenter.format(result)

        File.open("environments/#{environment_name}.json", "w") do |f|
          f.puts json
        end
      end

      def presenter
        @presenter ||= ui.instance_variable_get("@presenter")
      end

      def sort_hash(hash)
        sorted = hash.sort { |a,b| a[0] <=> b[0] }.map do |k,v|
          [k, sort_attribute_value(v)]
        end
        Hash[sorted]
      end

      def sort_attribute_value(value)
        case value
        when Array
          value
        when Hash
          Hash[value.sort { |a,b| a[0] <=> b[0] }]
        else
          value
        end
      end
    end
  end
end
