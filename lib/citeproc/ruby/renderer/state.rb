module CiteProc
  module Ruby
    class Renderer

      def citation_mode?
        state.mode == 'citation'
      end

      def bibliography_mode?
        state.mode == 'bibliography'
      end

      def sort_mode?
        state.mode == 'key'
      end

      def substitution_mode?
        !state.substitute.nil?
      end

      class State
        include Observable

        attr_reader :history, :node, :item, :authors, :substitute

        def initialize
          @history = History.new(self, 3)
        end

        def store!(item, node)
          @item, @node = item, node
        ensure
          changed
        end

        def store_authors!(authors)
          @authors = authors
        ensure
          changed
        end

        def clear!(result = nil)
          memories = conserve(result)
          @item, @node, @substitute, @authors = nil, nil, nil, nil
        ensure
          changed
          notify_observers :clear!, memories.delete(:mode), memories
        end

        def mode
          node && node.nodename
        end

        def substitute!(names)
          @substitute = names
        end

        def clear_substitute!(backup = nil)
          @substitute = backup
        end

        def subsequent?
          return false unless item

          past = history.recall(mode)
          return false unless past && !past.empty?

          item.id == past[:item].id
        end

        def previous_authors
          past = history.recall(mode)
          return unless past && !past.empty?

          past[:authors]
        end

        def conserve(result = nil)
          {
            :mode => mode,
            :item => item,
            :authors => authors,
            :result => result
          }
        end
      end

    end
  end
end