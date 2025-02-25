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
    date_of_death: Date.new(2020, 1, 15),
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
    date_of_death: Date.new(2021, 3, 10),
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
    date_of_death: Date.new(2019, 12, 5),
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
    date_of_death: Date.new(2022, 6, 30),
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
    date_of_death: Date.new(2010, 11, 15),
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

  parent_mother = FamilyMember.create!(
    first_name: "Karen",
    last_name: "Anderson",
    birth_last_name: "Anderson",
    date_of_birth: Date.new(1955, 2, 20),
    birth_place: "Portland",
    birth_time: Time.new(1955, 2, 20, 6, 45),
    gender: 2,
    religion: "None",
    deceased: true,
    date_of_death: Date.new(2015, 7, 10),
    death_time: Time.new(2015, 7, 10, 14, 0),
    death_place: "Portland General Hospital",
    cause_of_death: "Illness",
    burial_date: Date.new(2015, 7, 15),
    burial_place: "Rosewood Cemetery",
    internment_place: "Family Crypt",
    profession: "Nurse",
    hobbies_and_interests: "Cooking, Gardening",
    short_description: "A loving and caring mother.",
    short_message: "Forever in our hearts.",
    family: family
  )

  parent_father = FamilyMember.create!(
    first_name: "Michael",
    last_name: "Anderson",
    birth_last_name: "Anderson",
    date_of_birth: Date.new(1950, 11, 5),
    birth_place: "Portland",
    birth_time: Time.new(1950, 11, 5, 8, 0),
    gender: 1,
    religion: "None",
    deceased: true,
    date_of_death: Date.new(2010, 3, 20),
    death_time: Time.new(2010, 3, 20, 10, 30),
    death_place: "Portland Medical Center",
    cause_of_death: "Natural Causes",
    burial_date: Date.new(2010, 3, 25),
    burial_place: "Greenwood Cemetery",
    internment_place: "Family Mausoleum",
    profession: "Mechanic",
    hobbies_and_interests: "Fishing, Woodworking",
    short_description: "A strong and supportive father.",
    short_message: "In eternal memory.",
    family: family
  )

  main_person = FamilyMember.create!(
    first_name: "Alice",
    last_name: "Johnson",
    birth_last_name: "Smith",
    date_of_birth: Date.new(1980, 4, 15),
    birth_place: "Seattle",
    birth_time: Time.new(1980, 4, 15, 10, 0),
    gender: 2,
    religion: "None",
    deceased: true,
    date_of_death: Date.new(2023, 1, 10),
    death_time: Time.new(2023, 1, 10, 20, 30),
    death_place: "Seattle General Hospital",
    cause_of_death: "Natural Causes",
    burial_date: Date.new(2023, 1, 15),
    burial_place: "Evergreen Cemetery",
    internment_place: "Family Crypt",
    profession: "Doctor",
    hobbies_and_interests: "Reading, Traveling, Cooking",
    short_description: "A caring and intelligent woman with a passion for helping others.",
    short_message: "Forever remembered and cherished.",
    family: family,
    mother: parent_mother,
    father: parent_father
  )

  spouse = FamilyMember.create!(
    first_name: "Robert",
    last_name: "Johnson",
    birth_last_name: "Johnson",
    date_of_birth: Date.new(1978, 11, 22),
    birth_place: "San Francisco",
    birth_time: Time.new(1978, 11, 22, 9, 45),
    gender: 1,
    religion: "None",
    deceased: true,
    date_of_death: Date.new(2022, 12, 31),
    death_time: Time.new(2022, 12, 31, 18, 0),
    death_place: "San Francisco Medical Center",
    cause_of_death: "Accident",
    burial_date: Date.new(2023, 1, 5),
    burial_place: "Oakland Cemetery",
    internment_place: "Family Vault",
    profession: "Lawyer",
    hobbies_and_interests: "Golf, Reading",
    short_description: "A dedicated partner and accomplished lawyer.",
    short_message: "In loving memory.",
    family: family
  )

  Marriage.create!(
    first_partner: main_person,
    second_partner: spouse,
    period: "2005-2020"
  )

  child1 = FamilyMember.create!(
    first_name: "David",
    last_name: "Johnson",
    birth_last_name: "Johnson",
    date_of_birth: Date.new(2006, 6, 30),
    birth_place: "Seattle",
    birth_time: Time.new(2006, 6, 30, 7, 30),
    gender: 1,
    religion: "None",
    deceased: false,
    profession: "Student",
    hobbies_and_interests: "Soccer, Video Games",
    short_description: "Energetic and talented child.",
    short_message: "Shining star of the family.",
    family: family,
    mother: main_person
  )

  child2 = FamilyMember.create!(
    first_name: "Sara",
    last_name: "Johnson",
    birth_last_name: "Johnson",
    date_of_birth: Date.new(2008, 9, 15),
    birth_place: "Seattle",
    birth_time: Time.new(2008, 9, 15, 8, 0),
    gender: 2,
    religion: "None",
    deceased: false,
    profession: "Student",
    hobbies_and_interests: "Dancing, Painting",
    short_description: "Creative and joyful.",
    short_message: "The light of our lives.",
    family: family,
    mother: main_person
  )

  sibling = FamilyMember.create!(
    first_name: "Emily",
    last_name: "Johnson",
    birth_last_name: "Johnson",
    date_of_birth: Date.new(1982, 3, 5),
    birth_place: "Seattle",
    birth_time: Time.new(1982, 3, 5, 11, 15),
    gender: 2,
    religion: "None",
    deceased: false,
    profession: "Designer",
    hobbies_and_interests: "Photography, Traveling",
    short_description: "A creative soul with a warm heart.",
    short_message: "Always inspiring.",
    family: family,
    mother: parent_mother,
    father: parent_father
  )

  maternal_grandmother = FamilyMember.create!(
    first_name: "Linda",
    last_name: "Roberts",
    birth_last_name: "Roberts",
    date_of_birth: Date.new(1930, 8, 12),
    birth_place: "Portland",
    birth_time: Time.new(1930, 8, 12, 7, 30),
    gender: 2,
    religion: "None",
    deceased: true,
    date_of_death: Date.new(1998, 5, 1),
    death_time: Time.new(1998, 5, 1, 12, 0),
    death_place: "Portland Hospital",
    cause_of_death: "Old Age",
    burial_date: Date.new(1998, 5, 5),
    burial_place: "Old Town Cemetery",
    internment_place: "Family Vault",
    profession: "Homemaker",
    hobbies_and_interests: "Reading, Knitting",
    short_description: "A gentle and wise lady.",
    short_message: "Missed dearly.",
    family: family
  )

  maternal_grandfather = FamilyMember.create!(
    first_name: "Robert",
    last_name: "Roberts",
    birth_last_name: "Roberts",
    date_of_birth: Date.new(1928, 4, 25),
    birth_place: "Portland",
    birth_time: Time.new(1928, 4, 25, 6, 45),
    gender: 1,
    religion: "None",
    deceased: true,
    date_of_death: Date.new(1995, 9, 10),
    death_time: Time.new(1995, 9, 10, 11, 30),
    death_place: "Portland General Hospital",
    cause_of_death: "Heart Failure",
    burial_date: Date.new(1995, 9, 15),
    burial_place: "Old Town Cemetery",
    internment_place: "Family Mausoleum",
    profession: "Farmer",
    hobbies_and_interests: "Gardening, Reading",
    short_description: "A hardworking man with a kind heart.",
    short_message: "Forever in our memories.",
    family: family
  )

  paternal_grandmother = FamilyMember.create!(
    first_name: "Susan",
    last_name: "Thompson",
    birth_last_name: "Thompson",
    date_of_birth: Date.new(1932, 12, 5),
    birth_place: "Portland",
    birth_time: Time.new(1932, 12, 5, 8, 15),
    gender: 2,
    religion: "None",
    deceased: true,
    date_of_death: Date.new(2000, 1, 20),
    death_time: Time.new(2000, 1, 20, 13, 0),
    death_place: "Portland Hospital",
    cause_of_death: "Cancer",
    burial_date: Date.new(2000, 1, 25),
    burial_place: "Greenwood Cemetery",
    internment_place: "Family Vault",
    profession: "Teacher",
    hobbies_and_interests: "Reading, Traveling",
    short_description: "A beloved grandmother with a gentle spirit.",
    short_message: "In loving memory.",
    family: family
  )

  paternal_grandfather = FamilyMember.create!(
    first_name: "Richard",
    last_name: "Thompson",
    birth_last_name: "Thompson",
    date_of_birth: Date.new(1930, 7, 15),
    birth_place: "Portland",
    birth_time: Time.new(1930, 7, 15, 9, 0),
    gender: 1,
    religion: "None",
    deceased: true,
    date_of_death: Date.new(1999, 4, 10),
    death_time: Time.new(1999, 4, 10, 10, 45),
    death_place: "Portland Medical Center",
    cause_of_death: "Stroke",
    burial_date: Date.new(1999, 4, 15),
    burial_place: "Greenwood Cemetery",
    internment_place: "Family Mausoleum",
    profession: "Retired",
    hobbies_and_interests: "Fishing, Woodworking",
    short_description: "A kind and wise man, always full of advice.",
    short_message: "Remembered with love.",
    family: family
  )

end
