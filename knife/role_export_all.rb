require 'chef/knife'
require 'chef/knife/core/node_presenter'

module ZephirWorks
  class Knife
    class RoleExportAll < Chef::Knife

      deps do
        require 'chef/node'
        require 'chef/json_compat'
      end

      banner "knife role export all (options)"

      def run
        config[:format] = "json"
        ui.use_presenter Chef::Knife::Core::NodePresenter

        print "Exporting"
        roles = list

        roles.each do |role_name|
          export(role_name)
          print "."
        end
        puts "\n"
      end

    protected
      def list
        Chef::Role.list.keys
      end

      def export(role_name)
        role = Chef::Role.load(role_name)

        result = {}
        result["name"] = role.name
        result["description"] = role.description
        result["json_class"] = role.class.name
        result["default_attributes"] = sort_hash(role.default_attributes)
        result["override_attributes"] = sort_hash(role.override_attributes)
        result["chef_type"] = "role"
        result["run_list"] = role.run_list
        role.env_run_lists.delete("_default")
        result["env_run_lists"] = role.env_run_lists

        json = presenter.format(result)

        File.open("roles/#{role_name}.json", "w") do |f|
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
