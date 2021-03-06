# Copyright 2011, Dell 
# 
# Licensed under the Apache License, Version 2.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at 
# 
#  http://www.apache.org/licenses/LICENSE-2.0 
# 
# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an "AS IS" BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and 
# limitations under the License. 
# 

class KeystoneService < ServiceObject

  def initialize(thelogger)
    @bc_name = "keystone"
    @logger = thelogger
  end
# Turn off multi proposal support till it really works and people ask for it.
  def self.allow_multiple_proposals?
    false
  end

  def proposal_dependencies(role)
    answer = []
    if role.default_attributes[@bc_name]["percona"] == "percona"
      answer << { "barclamp" => "percona", "inst" => role.default_attributes["keystone"]["database_instance"] }
    end
    if role.default_attributes[@bc_name]["use_gitrepo"]
      answer << { "barclamp" => "git", "inst" => role.default_attributes[@bc_name]["git_instance"] }
    end
    answer
  end

  def create_proposal
    base = super

    nodes = NodeObject.all
    nodes.delete_if { |n| n.nil? or n.admin? }

#    base["attributes"]["keystone"]["database_instance"] = ""
#    begin
#      perconaService = perconaService.new(@logger)
#      # Look for active roles
#      dbs = perconaService.list_active[1]
#      if dbs.empty?
#        # No actives, look for proposals
#        dbs = perconaService.proposals[1]
#      end
#      if dbs.empty?
#        @logger.info("Keystone create_proposal: no percona proposal found")
#        base["attributes"]["keystone"]["database_instance"] = ""
#      else
#        base["attributes"]["keystone"]["database_instance"] = dbs[0]
#        base["attributes"]["keystone"]["database_engine"] = "percona"
#        @logger.info("Keystone create_proposal: using database proposal: '#{dbs[0]}'")
#      end
#    rescue
#      @logger.info("Keystone create_proposal: no percona proposal found")
#      base["attributes"]["keystone"]["database_engine"] = ""
#    end

    # SQLite is not a fallback solution
    # base["attributes"]["keystone"]["database_engine"] = "sqlite" if base["attributes"]["keystone"]["database_engine"] == ""
#    if base["attributes"]["keystone"]["database_engine"] == ""
#      raise(I18n.t('model.service.dependency_missing', :name => @bc_name, :dependson => "percona"))
#    end
    
#    base["attributes"][@bc_name]["git_instance"] = ""
#    begin
#      gitService = GitService.new(@logger)
#      gits = gitService.list_active[1]
#      if gits.empty?
#        # No actives, look for proposals
#        gits = gitService.proposals[1]
#      end
#      unless gits.empty?
#        base["attributes"][@bc_name]["git_instance"] = gits[0]
#      end
#    rescue
#      @logger.info("#{@bc_name} create_proposal: no git found")
#    end

    base["deployment"]["keystone"]["elements"] = {
        "keystone-server" => [ nodes.first[:fqdn] ]
    } unless nodes.nil? or nodes.length ==0

    base[:attributes][:keystone][:service][:token] = '%012d' % rand(1e12)

    base
  end
  
  def apply_role_pre_chef_call(old_role, role, all_nodes)

    role.default_attributes[:keystone][:db_user_password] = random_password
    role.save
	
  end
  
end

