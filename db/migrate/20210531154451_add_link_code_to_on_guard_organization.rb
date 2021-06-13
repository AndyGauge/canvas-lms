class AddLinkCodeToOnGuardOrganization < ActiveRecord::Migration[5.2]
  tag :predeploy
  def change
    add_column :on_guard_organizations, :link_code, :string
    add_index :on_guard_organizations,:link_code, unique:true

    OnGuard::Organization.all.each do |org|
      org.update(link_code: [*('A'..'Z'),*('0'..'9')].shuffle[0,8].join)
    end
  end
end
