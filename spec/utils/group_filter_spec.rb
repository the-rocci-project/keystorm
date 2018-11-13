# frozen_string_literal: true

require 'rails_helper'

describe Utils::GroupFilter, type: :model do
  describe '.run!' do
    let(:groups) do
      {
        'grp1' => %w[role1],
        'grp2' => %w[role1 role2],
        'grp3' => %w[role1 role2 role3],
        'grp4' => %w[role1 role2 role3 role4]
      }
    end

    context 'with empty filterfile' do
      let(:filtered) do
        stub_const('Utils::GroupFilter::FILTER_FILE_PATH', File.join(FILTER_FILES_DIR, 'empty.yml'))
        described_class.new.run!(groups)
      end

      it 'wont filter out any groups' do
        expect(filtered).to eq(groups)
      end
    end

    context 'with filterfile with 1 group' do
      context 'with no roles' do
        let(:filtered) do
          stub_const('Utils::GroupFilter::FILTER_FILE_PATH', File.join(FILTER_FILES_DIR, 'grp1n.yml'))
          described_class.new.run!(groups)
        end

        it 'will filter grp1' do
          expect(filtered).not_to have_key('grp1')
        end

        it 'wont delete other groups' do
          expect(groups).to include(filtered)
        end
      end

      context 'with same roles' do
        let(:filtered) do
          stub_const('Utils::GroupFilter::FILTER_FILE_PATH', File.join(FILTER_FILES_DIR, 'grp1.yml'))
          described_class.new.run!(groups)
        end

        it 'wont filter out any groups' do
          expect(filtered).to eq(groups)
        end
      end

      context 'with different roles' do
        let(:filtered) do
          stub_const('Utils::GroupFilter::FILTER_FILE_PATH', File.join(FILTER_FILES_DIR, 'grp1d.yml'))
          described_class.new.run!(groups)
        end

        it 'wont delete all groups' do
          expect(groups).to include(filtered)
        end

        it 'will filter out grp1' do
          expect(filtered).not_to have_key('grp1')
        end
      end

      context 'with intersectiong roles' do
        let(:filtered) do
          stub_const('Utils::GroupFilter::FILTER_FILE_PATH', File.join(FILTER_FILES_DIR, 'grp1i.yml'))
          described_class.new.run!(groups)
        end

        it 'will have grp4' do
          expect(filtered).to have_key('grp4')
        end

        it 'will have grp4 with 2 roles' do
          expect(filtered['grp4'].size).to eq(2)
        end
      end
    end

    context 'with filterfile with 2 groups' do
      context 'when both have roles' do
        let(:filtered) do
          stub_const('Utils::GroupFilter::FILTER_FILE_PATH', File.join(FILTER_FILES_DIR, 'grp2.yml'))
          described_class.new.run!(groups)
        end

        it 'wont delete any groups' do
          expect(filtered.keys).to eq(groups.keys)
        end

        it 'will delete role1 from grp2' do
          expect(filtered['grp2']).to eq(['role2'])
        end
      end
    end
  end
end
