# Coordinator account from ADMIN_EMAIL and ADMIN_PASSWORD, so no credential lives in the repository.
password = ENV["ADMIN_PASSWORD"]

if password.present?
  admin = User.find_or_initialize_by(email_address: ENV.fetch("ADMIN_EMAIL", "admin@example.com"))
  admin.update!(password: password, password_confirmation: password)
  puts "Coordinator account ready for #{admin.email_address}"
else
  puts "ADMIN_PASSWORD is not set, skipping the coordinator account"
end

return if ENV.fetch("LOAD_DEMO_DATA", "true") != "true" || Project.exists?

# Fictional demo data: people, companies and amounts are invented.
tutors = {
  sistemas: Tutor.create!(name: "Diana Marcela Rojas", faculty: "Facultad de Ingeniería", email: "drojas@universidad.example"),
  ambiental: Tutor.create!(name: "Andrés Felipe Cárdenas", faculty: "Facultad de Ciencias Ambientales", email: "acardenas@universidad.example"),
  medicina: Tutor.create!(name: "Laura Victoria Mejía", faculty: "Facultad de Medicina", email: "lmejia@universidad.example"),
  agronomia: Tutor.create!(name: "Carlos Eduardo Pinzón", faculty: "Facultad de Ciencias Agrarias", email: "cpinzon@universidad.example")
}

sponsors = {
  andina: Sponsor.create!(name: "Andina Tecnología S.A.S.", kind: :company, nit: "900512384-5", phone: "6017456200", email: "alianzas@andina.example"),
  cafe: Sponsor.create!(name: "Cooperativa Cafetera del Sur", kind: :company, nit: "830047219-1", phone: "6088723400", email: "proyectos@cafesur.example"),
  agua: Sponsor.create!(name: "Fundación Agua Viva", kind: :ngo, nit: "901233457-0", phone: "3104567890", email: "contacto@aguaviva.example"),
  gobernacion: Sponsor.create!(name: "Secretaría Departamental de Ciencia", kind: :public_entity, nit: "899999123-7", phone: "6043839000", email: "ciencia@departamento.example"),
  salud: Sponsor.create!(name: "Clínica Universitaria del Norte", kind: :university, nit: "860517302-1", phone: "6053600900", email: "investigacion@clinica.example"),
  bici: Sponsor.create!(name: "Movilidad Verde S.A.S.", kind: :company, nit: "900874120-0", phone: "3157654321", email: "hola@movilidadverde.example")
}

[
  {
    title: "Alerta temprana de deslizamientos con sensores IoT",
    summary: "Red de sensores de humedad e inclinación en laderas con riesgo, con alertas por SMS a las juntas de acción comunal.",
    status: :in_progress, budget: 180_000_000, starts_on: Date.new(2026, 2, 2), tutor: tutors[:sistemas],
    lead: { name: "Valentina Ríos", program: "Ingeniería de Sistemas", semester: 9, email: "vrios@estudiantes.example" },
    sponsorships: { andina: 90_000_000, gobernacion: 60_000_000 }
  },
  {
    title: "Purificación de agua rural con filtros de biocarbón",
    summary: "Filtros de bajo costo con biocarbón de cascarilla de arroz para veredas sin acueducto.",
    status: :in_progress, budget: 95_000_000, starts_on: Date.new(2025, 8, 4), tutor: tutors[:ambiental],
    lead: { name: "Santiago Gómez", program: "Ingeniería Ambiental", semester: 8, email: "sgomez@estudiantes.example" },
    sponsorships: { agua: 55_000_000, gobernacion: 40_000_000 }
  },
  {
    title: "Detección de roya en cafetales con visión por computador",
    summary: "Modelo de clasificación de hojas para identificar roya en etapas tempranas desde fotos tomadas con el celular.",
    status: :proposed, budget: 120_000_000, tutor: tutors[:agronomia],
    sponsorships: { cafe: 30_000_000 }
  },
  {
    title: "Prótesis de mano impresa en 3D para niños",
    summary: "Diseño abierto de prótesis mecánicas ajustables al crecimiento, impresas en PLA y validadas con pacientes.",
    status: :completed, budget: 70_000_000, starts_on: Date.new(2024, 2, 5), tutor: tutors[:medicina],
    lead: { name: "Mariana Ospina", program: "Ingeniería Biomédica", semester: 10, email: "mospina@estudiantes.example" },
    sponsorships: { salud: 45_000_000, andina: 25_000_000 }
  },
  {
    title: "Rutas seguras en bicicleta para la ciudad universitaria",
    summary: "Aplicación que recomienda rutas en bicicleta según iluminación, ciclorrutas y reportes de incidentes.",
    status: :proposed, budget: 60_000_000, tutor: tutors[:sistemas],
    lead: { name: "Juan Pablo Herrera", program: "Ingeniería de Sistemas", semester: 7, email: "jpherrera@estudiantes.example" },
    sponsorships: { bici: 18_000_000 }
  },
  {
    title: "Huertas hidropónicas en colegios públicos",
    summary: "Huertas escolares con sistemas NFT de bajo costo y guías pedagógicas para docentes de ciencias.",
    status: :proposed, budget: 45_000_000, tutor: tutors[:agronomia]
  }
].each do |attributes|
  project = Project.create!(attributes.slice(:title, :summary, :status, :budget, :starts_on, :tutor))
  project.create_student_lead!(attributes[:lead]) if attributes[:lead]

  attributes.fetch(:sponsorships, {}).each do |sponsor_key, amount|
    project.sponsorships.create!(sponsor: sponsors.fetch(sponsor_key), amount: amount, committed_on: project.starts_on || Date.new(2026, 10, 1))
  end
end

puts "Demo data: #{Project.count} projects, #{Sponsorship.count} sponsorships"
