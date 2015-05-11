#
#
# == License:
# Fairmondo - Fairmondo is an open-source online marketplace.
# Copyright (C) 2013 Fairmondo eG
#
# This file is part of Fairmondo.
#
# Fairmondo is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Fairmondo is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Fairmondo.  If not, see <http://www.gnu.org/licenses/>.
#
class UserPolicy < Struct.new(:user, :resource)
  def profile?
    true unless banned?
  end

  def show?
    true unless banned?
  end

  def show_private_for_legal?
    user.is_a?(LegalEntity) && own?
  end

  def show_private_for_private?
    user.is_a?(PrivateUser) && own?
  end

  private

  def banned?
    resource.banned?
  end

  def own?
    user == resource
  end
end
