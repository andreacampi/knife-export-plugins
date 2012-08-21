require 'chef/knife'
require 'chef/knife/core/node_presenter'

module ZephirWorks
  class Knife
    class NodeExportAll < Chef::Knife

      deps do
        require 'chef/node'
        require 'chef/json_compat'
      end

      banner "knife node export all (options)"

      def run
        config[:format] = "json"
        ui.use_presenter Chef::Knife::Core::NodePresenter

        print "Exporting"
        nodes = list

        nodes.each do |node_name|
          export(node_name)
          print "."
        end
        puts "\n"
      end

    protected
      def env
        @_env ||= Chef::Config[:environment]
      end

      def list
        (env ? Chef::Node.list_by_environment(env) : Chef::Node.list).keys
      end

      def export(node_name)
        node = Chef::Node.load(node_name)

        result = {}
        result["name"] = node.name
        result["chef_environment"] = node.chef_environment
        result["run_list"] = node.run_list

        normals = node.normal_attrs.dup
        normals.delete("log")
        sorted = normals.sort { |a,b| a[0] <=> b[0] }.map do |k,v|
          [k, sort_attribute_value(v)]
        end
        result["normal"] = Hash[sorted]

        json = presenter.format(result)

        File.open("nodes/#{node_name}.json", "w") do |f|
          f.puts json
        end
      end

      def presenter
        @presenter ||= ui.instance_variable_get("@presenter")
      end

      def sort_attribute_value(value)
        case value
        when Array
          value
        when Hash
          Hash[value.map { |k,v| [k, sort_attribute_value(v)] }.sort { |a,b| a[0] <=> b[0] }]
        else
          value
        end
      end
    end
  end
end
