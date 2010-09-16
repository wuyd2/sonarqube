#
# Sonar, entreprise quality control tool.
# Copyright (C) 2009 SonarSource SA
# mailto:contact AT sonarsource DOT com
#
# Sonar is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 3 of the License, or (at your option) any later version.
#
# Sonar is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with Sonar; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02
#
class Characteristic < ActiveRecord::Base
  NAME_MAX_SIZE=100

  has_and_belongs_to_many :children, :class_name => 'Characteristic', :join_table => 'characteristic_edges',
    :foreign_key => 'parent_id', :association_foreign_key => 'child_id', :order => 'characteristic_order ASC'

  has_and_belongs_to_many :parents, :class_name => 'Characteristic', :join_table => 'characteristic_edges',
    :foreign_key => 'child_id', :association_foreign_key => 'parent_id'

  belongs_to :rule
  belongs_to :quality_model
  
  validates_uniqueness_of :name, :scope => :quality_model_id, :case_sensitive => false, :if => Proc.new { |c| c.rule_id.nil? }
  validates_length_of :name, :in => 1..100, :allow_blank => false, :if => Proc.new { |c| c.rule_id.nil? }
  validates_presence_of :quality_model

  def root?
    depth==1
  end

  def key
    kee
  end

  def name(rule_name_if_empty=false)
    result=read_attribute(:name)
    if (result.nil? && rule_name_if_empty && rule_id)
      result=rule.name  
    end
    result
  end

  # return the first parent
  def parent
    parents.empty? ? nil : parents[0]
  end
end