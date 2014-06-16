#
# Farinopoly - Fairnopoly is an open-source online marketplace.
# Copyright (C) 2013 Fairnopoly eG
#
# This file is part of Farinopoly.
#
# Farinopoly is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Farinopoly is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Farinopoly.  If not, see <http://www.gnu.org/licenses/>.
#
require 'test_helper'

include Warden::Test::Helpers

feature 'Article Template management' do

  before do
    @user = FactoryGirl.create :user
    login_as @user, scope: :user
  end

  scenario "article template creation has at least one correct label for the questionnaires" do
    visit new_article_template_path
    page.must_have_content( I18n.t 'formtastic.labels.fair_trust_questionnaire.support')
  end

end

