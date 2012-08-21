require 'chef/knife'

module ZephirWorks
  class Knife
    class DataBagExportAll < Chef::Knife

      deps do
        require 'chef/data_bag'
      end

      banner "knife data bag export all (options)"

      def run
        config[:format] = "json"

        print "Exporting"
        bags = list

        bags.each do |bag_name, bag_url|
          next if %w[djbdns machines].include?(bag_name)

          export_bag(bag_name)
          print "."
        end
        puts "\n"
      end

    protected
      def list
        Chef::DataBag.list
      end

      def export_bag(bag_name)
        bag = Chef::DataBag.load(bag_name)

        bag.each do |bag_entry_name, bag_entry_url|
          export_entry(bag_name, bag_entry_name)
          print "_"
        end
      end

      def export_entry(bag_name, bag_entry_name)
        entry = Chef::DataBagItem.load(bag_name, bag_entry_name).raw_data
        
        result = sort_entry_keys(bag_name, entry)
        json = presenter.format(result)

        FileUtils.mkdir_p("data_bags/#{bag_name}")
        File.open("data_bags/#{bag_name}/#{bag_entry_name}.json", "w") do |f|
          f.puts json
        end
      end

      def presenter
        @presenter ||= ui.instance_variable_get("@presenter")
      end

      def sort_entry_keys(bag_name, entry)
        method_name = "sort_#{bag_name}"

        return send(method_name, entry) if respond_to?(method_name)

        result = {}
        result["id"] = entry["id"]
        entry.each do |k,v|
          next if k == "id"
          result[k] = sort_attribute_value(v)
        end
        result
      end

      def sort_apps(entry)
        result = {}

        %w[id server_roles type environments_map database_master_role repository
          revision force migrate databases deploy_key deploy_to owner group gems
          packages pears local_settings_file shared_files migration_command].each do |key|
          result[key] = sort_attribute_value(entry[key]) if entry.has_key?(key)
        end

        result
      end

      def sort_users(entry)
        result = {}

        %w[id ssh_keys groups uid gid shell comment forward htpasswd openvpn zenoss].each do |key|
          result[key] = sort_attribute_value(entry[key]) if entry.has_key?(key)
        end

        result
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
