applications_config = {
  "whitehall": {
    name: "Whitehall",
    permissions: []
  },
  "publisher": {
    name: "Publisher",
    permissions: [ "skip_review" ]
  },
  "travel-advice-publisher": {
    name: "Travel Advice Publisher",
    permissions: [ "gds_editor" ]
  },
  "manuals-publisher": {
    name: "Manuals Publisher",
    permissions: [ "editor", "gds_editor" ]
  },
  "specialist-publisher": {
    name: "Specialist Publisher",
    permissions: [ "editor", "gds_editor" ],
  },
  "collections-publisher": {
    name: "Collections Publisher",
    permissions: [ "GDS Editor" ]
  },
  "content-tagger": {
    name: "Content Tagger",
    permissions: [ "GDS Editor" ]
  },
  "asset-manager": {
    name: "Asset Manager",
    permissions: [],
  },
  "draft-origin": {
    name: "Content Preview",
    permissions: []
  }
}

applications = applications_config.map do |repo_name, app_config|
  app = Doorkeeper::Application.create!(
    name: app_config[:name],
    uid: repo_name,
    secret: "secret",
    redirect_uri: Plek.find(repo_name) + "/auth/gds/callback"
  )
  app_config[:permissions].each do |permission_name|
    SupportedPermission.create(name: permission_name, application: app)
  end
  [repo_name, app]
end.to_h

organisation = Organisation.create!(
  name: "Test Organisation",
  slug: "test-organisation",
  organisation_type: "Other",
  content_id: "Top Drawer"
)

User.create!(
  name: "Test 0",
  email: "test@example.com",
  password: "saveabonobo+20",
  password_confirmation: "saveabonobo+20",
  confirmation_token: "cake",
  confirmed_at: DateTime.now,
  organisation: organisation,
  role: "superadmin"
)

User.create!(
  name: "Test 1",
  email: "test1@example.com",
  password: "saveabonobo+20",
  password_confirmation: "saveabonobo+20",
  confirmation_token: "cake",
  confirmed_at: DateTime.now,
  organisation: organisation
)


api_user = ApiUser.create!(
  name: "API User",
  email: "api@example.com",
  password: "saveabonobo+20",
  password_confirmation: "saveabonobo+20",
  confirmation_token: "cake",
  confirmed_at: DateTime.now,
  api_user: 1
)

authorisation = api_user.authorisations.create!(
  expires_in: ApiUser::DEFAULT_TOKEN_LIFE,
  application_id: applications[:"asset-manager"].id
)

api_user.grant_application_permission(
  authorisation.application,
  'signin'
)

authorisation.update(token: "180")
