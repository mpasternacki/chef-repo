name "base"
description "Base role applied to all nodes."

run_list(
  "recipe[apt]",
  "recipe[users::sysadmins]", 
  "recipe[sudo]" )

default_attributes(
  :authorization => { :sudo => { :passwordless => true } }
  )

#override_attributes()
