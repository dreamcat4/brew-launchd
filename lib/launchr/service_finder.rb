
require 'launchr/path'
require 'launchr/config'
require 'launchr/service'

module Launchr
  class ServiceFinder

    def find svc
      unless Launchr::Path.homebrew_prefix
        raise "No homebrew prefix was found"
      end

      prefix = Launchr::Path.homebrew_prefix
      formula_name = nil
      formula_plists = []
      selected_plists = []
      
      # puts "prefix = #{prefix.inspect}"

      installed_plists = Dir.glob("#{prefix}/Library/LaunchDaemons/*")
      # installed_plists_realpaths = installed_plists.map { |p| Pathname.new(p).realpath.to_s }

      case svc
      when /^[^\.]+$/
        # its not a label or filename
        # so should be a formula name, or formula alias name

        if File.exists?("#{prefix}/Library/Aliases/#{svc}")
          # its an alias
          alias_realpath = Pathname.new("#{prefix}/Library/Aliases/#{svc}").realpath
          formula_name = alias_realpath.basename(".rb").to_s
        end

        if File.exists?("#{prefix}/Library/Formula/#{svc}.rb")
          # its a formula name
          # puts "#{prefix}/Library/Formula/#{svc}.rb"
          # Dir.glob "#{Launchr::Path.homebrew_prefix}/Cellar/#{svc}/"
          formula_name = svc
        end

        if formula_name
          # wrong
          # formula_plists << installed_plists_realpaths.select { |p| p.include? "Cellar\/#{formula_name}" }
          # should_be
          # formula_plists << installed_plists.select { |p| p.realpath.to_s.include? "Cellar\/#{formula_name}" }
          formula_plists = installed_plists.select { |p| Pathname.new(p).realpath.to_s.include? "Cellar\/#{formula_name}" }
          selected_plists = formula_plists.dup
        end

      else
        # lookup the label filename
        label = File.basename(svc,".plist")
        plist_link = "#{prefix}/Library/LaunchDaemons/#{label}.plist"
        if File.exists?(plist_link)
          # its a label
          plist_realpath = Pathname.new(plist_link).realpath
          # if the plist was started, it will point to the target

          formula_name = plist_realpath.to_s.gsub(/^.*Cellar\/|\/.*$/,"")
          # wrong
          # formula_plists << installed_plists_realpaths.select { |p| p.include? "Cellar\/#{formula_name}" }
          # should_be
          # formula_plists << installed_plists.select { |p| p.realpath.to_s.include? "Cellar\/#{formula_name}" }
          formula_plists = installed_plists.select { |p| Pathname.new(p).realpath.to_s.include? "Cellar\/#{formula_name}" }
          selected_plists << plist_realpath.to_s
        end
      end

      unless formula_name
        raise "Service #{svc} not found"
      end

      Launchr::Service.new(formula_name, formula_plists, selected_plists)
    end



    # def initialize *args, &blk
    #   # resolve_watch_paths
    # 
    #   # if Launchr::Path.homebrew_prefix
    #   #   @path 
    #   # else
    #   #   raise "No homebrew prefix was found"
    #   # end
    # end
    # 
    # def resolve_watch_paths_old
    #   Launchr::Config[:watch_paths].compact!
    #   
    #   if Launchr::Path.homebrew_prefix
    #     # if not already present, we must re-install the daemon
    #     # touch a known existing path to trigger the launchr daemon to reinstall itself
    #     Launchr::Config[:watch_paths] << "#{Launchr::Path.homebrew_prefix}/Library/LaunchDaemons"
    #     Launchr::Config[:watch_paths].uniq!
    #   end
    # 
    #   if Launchr::Config[:watch_paths].empty?
    #     # raise error - no watch paths have been set up
    #   end
    # end
    # 
    # def find_old svc
    #   resolve_svc svc
    # end
    # 
    # def resolve_svc_for_path_old path, svc
    #   puts path.to_s
    #   puts svc.to_s
    # 
    #   case svc
    #   when /^[^\.]+$/
    #     # try to convert from alias first
    #     if File.exists?("#{path}/../../Library/Aliases/#{svc}")
    #       # its an alias
    #       alias_realpath = Pathname.new("#{path}/../../Library/Aliases/#{svc}").realpath
    #       formula_name = alias_realpath.basename(".rb").to_s
    #     end
    # 
    #     if File.exists?("#{path}/../../Library/Formula/#{svc}.rb")
    #       # its a formula name
    #       puts "#{path}/../../Library/Formula/#{svc}.rb"
    #       # Dir.glob "#{Launchr::Path.homebrew_prefix}/Cellar/#{svc}/"
    #       formula_name = svc
    #     end
    # 
    #     if formula_name
    #       # read the realpaths in the watch path
    #       # return matches to formula_name
    #     end
    # 
    #   else
    #     # lookup the label filename
    #     label = File.basename(svc,".plist")
    #     if File.exists?("#{path}/#{label}.plist")
    #       # its a label
    #     end
    #   end
    # end
    # 
    # def resolve_svc_old svc
    #   puts svc.inspect
    # 
    #   watch_paths = []
    #   if svc =~ /:/
    #     # its got a watch path label
    #     labels = Launchr::Config[:watch_path_labels]
    #     label = svc.gsub(/:.*$/,"")
    #     if labels.include?(label)
    #       wpi = labels.index(label)
    #       watch_paths << Launchr::Config[:watch_paths][wpi]
    #       svc.gsub!(/:.*$/,"")
    #     else
    #       # raise error - no label found
    #     end
    #   else
    #     if Launchr::Path.homebrew_prefix
    #       watch_paths << resolve_svc_for_path Launchr::Path.homebrew_prefix
    #     end
    #     watch_paths += Launchr::Config[:watch_paths] - [Launchr::Path.homebrew_prefix]
    #   end
    # 
    #   watch_paths.each do |watch_path|
    #     resolve_svc_for_path watch_path, svc
    #   end
    # end
    
    
    
  end
end



