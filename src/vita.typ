#import "../resume_typst/src/lib_cv.typ": *

// Import all sections
#import "../resume_typst/src/sections/education.typ": education
#import "../resume_typst/src/sections/research_interests.typ": research_interests
#import "../resume_typst/src/sections/publications.typ": publications_section
#import "../resume_typst/src/sections/ongoing_research.typ": ongoing_research
#import "../resume_typst/src/sections/work_experience.typ": work_experience
#import "../resume_typst/src/sections/selected_projects.typ": selected_projects
#import "../resume_typst/src/sections/mentorship.typ": mentorship
#import "../resume_typst/src/sections/academic_services.typ": academic_services
#import "../resume_typst/src/sections/press_releases.typ": press_releases
#import "../resume_typst/src/sections/technical_skills.typ": technical_skills_section
#import "../resume_typst/src/sections/personal_info.typ": personal_info
#import "../resume_typst/src/sections/proposal_writing.typ": proposal_writing
#import "../resume_typst/src/sections/honors.typ": honors

// #set text(size: 0.7em, font: fonts.body)
#set par(leading: 1em)
#set block(spacing: 0em)
#show link: it => text(fill: primary_color, underline(it))


// Header
// #v(-2em)
#cv_header(
  "Bassel El Mabsout",
  cv_contact_box((
    (icon: "phone", text: "+1 (857) 939-8769"),
    (icon: "location", text: "Boston, MA, USA"),
    (icon: "email", text: link("mailto:bmabsout@bu.edu")),
    (icon: "globe", text: link("https://bmabsout.com")[bmabsout.com]),
    (icon: "github", text: link("https://github.com/bmabsout")[github.com/bmabsout]),
    (icon: "scholar", text: link("https://scholar.google.com/citations?user=Rxv9W98AAAAJ")[Google Scholar (Rxv9W98)])
  ))
)
#v(1em)
// Main content
#cv_sections(
  education,
  research_interests,
  publications_section,
  ongoing_research,
  proposal_writing,
  selected_projects,
  work_experience,
  press_releases,
  mentorship,
  academic_services,
  honors,
  technical_skills_section,
  personal_info
) 