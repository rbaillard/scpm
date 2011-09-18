class Milestone < ActiveRecord::Base

  belongs_to  :project
  has_many    :checklist_items, :dependent=>:destroy

  def date
    return self.actual_milestone_date if self.actual_milestone_date and self.actual_milestone_date!=""
    self.milestone_date
  end

  def to_s
    name
  end

  def passed_style
    return " passed" if done > 0 or status == -1
    return ""
  end

  def timealert
    return "passed" if done == 1
    return "skipped" if done == 2
    d = date
    if d.blank?
      return "missing" if status != -1
      return "blank"
    end
    diff = d - Date.today
    return "verysoon" if diff <= 5
    return "soon" if diff <= 10
    return "normal"
  end

  def amendments
    self.project.amendments.select{|a| a.milestone == self.name}
  end

  def checklist_not_allowed?
    self.checklist_not_applicable==1 or self.status!=0 or self.done!=0
  end

  def deploy_checklists
    return if checklist_not_allowed?

    self.project.requests.each { |r|
      next if !r.milestone_names.include?(self.name)
      for t in ChecklistItemTemplate.all.select{ |t|
          t.milestone_names.map{|n| n.title}.include?(self.name) and
          t.workpackages.map{|w| w.title}.include?(r.work_package)
          }
        deploy_checklist(t,r)
      end
      }
  end


  def deploy_checklist(template, request)
    p = template.find_or_deploy_parent(self,request)
    parent_id = p ? p.id : 0
    i = ChecklistItem.find(:first, :conditions=>["template_id=? and milestone_id=? and request_id=?", template.id, self.id, request.id])
    if not i
      ChecklistItem.create(:milestone_id=>self.id, :request_id=>request.id, :parent_id=>parent_id, :template_id=>template.id)
    else
      # parent change handling
      i.parent_id = parent_id
      i.save
      # if some milestone_names or workpackages have been added, the new ChecklistItem will be created
      # TODO: detect removal of milestones or workpackages and delete not already answered ChecklistItem
      # for is_transverse: TODO: if changed from no to yes, a lot of cleanup must be done
      # for yes to no, the ChecklistItems will be created
    end
  end

  def destroy_checklist
    ChecklistItem.destroy_all(["milestone_id=?", self.id])
  end

  #def rmt_alerts
  #  alerts = []
  #  alerts << "RMT milestone date is not the same" if self.name == 'm3' and project.requests.select{|r| r.milestone=="M1-M3"}.size > 0
  #  alerts
  #end

end

