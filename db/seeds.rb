if Rails.env.development?
  require "securerandom"

  account = Account.create!(
    status: 2,
    email: "john@doe.com",
    password: 'password'
  )

  family = Family.create!(
    uuid: SecureRandom.uuid,
    account_id: account.id
  )

  father = FamilyMember.create!(
    first_name: "John",
    last_name: "Doe",
    birth_last_name: "Doe",
    date_of_birth: Date.new(1965, 5, 10),
    birth_place: "New York",
    birth_time: Time.new(1965, 5, 10, 8, 30),
    gender: 1,
    religion: "Atheism",
    deceased: true,
    death_date: Date.new(2020, 1, 15),
    death_time: Time.new(2020, 1, 15, 22, 0),
    death_place: "New York Hospital",
    cause_of_death: "Heart Attack",
    burial_date: Date.new(2020, 1, 20),
    burial_place: "Greenwood Cemetery",
    internment_place: "Family Mausoleum",
    profession: "Engineer",
    hobbies_and_interests: "Fishing, Reading",
    short_description: "Loving father and dedicated engineer.",
    short_message: "Forever in our hearts.",
    family: family
  )

  mother = FamilyMember.create!(
    first_name: "Jane",
    last_name: "Smith",
    birth_last_name: "Smith",
    date_of_birth: Date.new(1967, 8, 15),
    birth_place: "Los Angeles",
    birth_time: Time.new(1967, 8, 15, 7, 45),
    gender: 2,
    religion: "Christianity",
    deceased: true,
    death_date: Date.new(2021, 3, 10),
    death_time: Time.new(2021, 3, 10, 18, 30),
    death_place: "LA Medical Center",
    cause_of_death: "Complications after surgery",
    burial_date: Date.new(2021, 3, 15),
    burial_place: "Rosewood Cemetery",
    internment_place: "Family Vault",
    profession: "Teacher",
    hobbies_and_interests: "Gardening, Painting",
    short_description: "Caring mother and beloved educator.",
    short_message: "Missed dearly.",
    family: family
  )

  Marriage.create!(
    first_partner: father,
    second_partner: mother,
    period: "1988-1990"
  )

  son = FamilyMember.create!(
    first_name: "Michael",
    last_name: "Doe",
    birth_last_name: "Doe",
    date_of_birth: Date.new(1990, 7, 20),
    birth_place: "Chicago",
    birth_time: Time.new(1990, 7, 20, 9, 15),
    gender: 1,
    religion: "None",
    deceased: true,
    death_date: Date.new(2019, 12, 5),
    death_time: Time.new(2019, 12, 5, 14, 0),
    death_place: "Chicago General Hospital",
    cause_of_death: "Accident",
    burial_date: Date.new(2019, 12, 10),
    burial_place: "Lakeside Cemetery",
    internment_place: "Family Plot",
    profession: "Software Developer",
    hobbies_and_interests: "Programming, Hiking, Chess",
    short_description: "Innovative developer with a passion for technology.",
    short_message: "A brilliant mind gone too soon.",
    family: family,
    father: father,
    mother: mother
  )

  Education.create!(
    family_member: son,
    school_name: "Chicago High School",
    address: "123 Main St, Chicago",
    period: "2004-2008"
  )
  Education.create!(
    family_member: son,
    school_name: "MIT",
    address: "77 Massachusetts Ave, Cambridge",
    period: "2008-2012"
  )

  Employment.create!(
    family_member: son,
    employer: "TechCorp",
    address: "456 Tech Park, Chicago",
    period: "2012-Present"
  )

  ResidenceAddress.create!(
    family_member: son,
    address: "789 Elm St, Chicago",
    period: "2015-Present"
  )

  AdditionalAttribute.create!(
    family_member: son,
    attribute_name: "Favorite Hobby",
    long_text: "Programming, Hiking, Reading"
  )

  daughter = FamilyMember.create!(
    first_name: "Emily",
    last_name: "Doe",
    birth_last_name: "Doe",
    date_of_birth: Date.new(1993, 9, 25),
    birth_place: "Chicago",
    birth_time: Time.new(1993, 9, 25, 11, 0),
    gender: 2,
    religion: "None",
    deceased: true,
    death_date: Date.new(2022, 6, 30),
    death_time: Time.new(2022, 6, 30, 16, 45),
    death_place: "Chicago Central Hospital",
    cause_of_death: "Illness",
    burial_date: Date.new(2022, 7, 5),
    burial_place: "Oakwood Cemetery",
    internment_place: "Family Crypt",
    profession: "Artist",
    hobbies_and_interests: "Painting, Sculpting, Music",
    short_description: "Creative soul with a unique vision.",
    short_message: "Her art lives on.",
    family: family,
    father: father,
    mother: mother
  )

  Education.create!(
    family_member: daughter,
    school_name: "Chicago High School",
    address: "123 Main St, Chicago",
    period: "2008-2012"
  )

  Employment.create!(
    family_member: daughter,
    employer: "DesignStudio",
    address: "321 Creative Ave, Chicago",
    period: "2012-Present"
  )

  ResidenceAddress.create!(
    family_member: daughter,
    address: "987 Oak St, Chicago",
    period: "2016-Present"
  )

  AdditionalAttribute.create!(
    family_member: daughter,
    attribute_name: "Art Style",
    long_text: "Impressionism, Modern Art"
  )

  grandmother = FamilyMember.create!(
    first_name: "Margaret",
    last_name: "Smith",
    birth_last_name: "Smith",
    date_of_birth: Date.new(1940, 3, 1),
    birth_place: "Boston",
    birth_time: Time.new(1940, 3, 1, 6, 0),
    gender: 2,
    religion: "Christianity",
    deceased: true,
    death_date: Date.new(2010, 11, 15),
    death_time: Time.new(2010, 11, 15, 10, 30),
    death_place: "Boston General Hospital",
    cause_of_death: "Natural causes",
    burial_date: Date.new(2010, 11, 20),
    burial_place: "Greenwood Cemetery",
    internment_place: "Family Mausoleum",
    profession: "Homemaker",
    hobbies_and_interests: "Knitting, Cooking",
    short_description: "A warm and loving grandmother.",
    short_message: "Forever remembered.",
    family: family
  )
end
