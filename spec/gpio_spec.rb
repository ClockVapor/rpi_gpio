require "spec_helper"

describe RPi::GPIO do
  before :each do
    RPi::GPIO.set_warnings false
    RPi::GPIO.reset
    RPi::GPIO.set_warnings false
  end

  after :each do
    RPi::GPIO.set_warnings false
    RPi::GPIO.reset
  end

  describe ".set_numbering" do
    context "before numbering is set" do
      it "doesn't raise an error given arg :board" do
        expect { RPi::GPIO.set_numbering :board } .to_not raise_error
      end

      it "doesn't raise an error given arg :bcm" do
        expect { RPi::GPIO.set_numbering :bcm } .to_not raise_error
      end

      it "raises an error given an invalid mode" do
        expect { RPi::GPIO.set_numbering :nope } .to raise_error ArgumentError
      end
    end

    context "after numbering is set" do
      before :each do
        RPi::GPIO.set_numbering :board
      end

      it "doesn't raise an error given arg :board" do
        expect { RPi::GPIO.set_numbering :board } .to_not raise_error
      end

      it "doesn't raise an error given arg :bcm" do
        expect { RPi::GPIO.set_numbering :bcm } .to_not raise_error
      end

      it "raises an error given an invalid mode" do
        expect { RPi::GPIO.set_numbering :nope } .to raise_error ArgumentError
      end
    end
  end

  describe ".set_warnings" do
    it "doesn't raise an error given arg true" do
      expect { RPi::GPIO.set_warnings true } .to_not raise_error
    end

    it "doesn't raise an error given arg false" do
      expect { RPi::GPIO.set_warnings false } .to_not raise_error
    end
  end

  describe ".reset" do
    before :each do
      RPi::GPIO.set_numbering :board
      RPi::GPIO.setup 18, :as => :input
      expect { RPi::GPIO.high? 18 } .to_not raise_error
      RPi::GPIO.reset
    end

    it "cleans up pins" do
      expect { RPi::GPIO.high? 18 } .to raise_error RuntimeError
    end

    it "unsets numbering mode" do
      expect { RPi::GPIO.setup 18, :as => :input } .to raise_error RuntimeError
    end
  end

  describe ".setup" do
    context "before numbering is set" do
      context "given a valid channel" do
        it "raises an error" do
          expect { RPi::GPIO.setup 18, :as => :input }
            .to raise_error RuntimeError
        end
      end

      context "given an invalid channel" do
        it "raises an error" do
          expect { RPi::GPIO.setup 0, :as => :input }
            .to raise_error RuntimeError
        end
      end
    end

    context "after numbering is set" do
      before :each do
        RPi::GPIO.set_numbering :board
      end

      context "given a valid, unset channel" do
        context "as input" do
          context "given no pull direction" do
            it "doesn't raise an error" do
              expect { RPi::GPIO.setup 18, :as => :input } .to_not raise_error
            end
          end

          context "given :off pull direction" do
            it "doesn't raise an error" do
              expect { RPi::GPIO.setup 18, :as => :input, :pull => :off }
                .to_not raise_error
            end
          end

          context "given :up pull direction" do
            it "doesn't raise an error" do
              expect { RPi::GPIO.setup 18, :as => :input, :pull => :up }
                .to_not raise_error
            end
          end

          context "given :down pull direction" do
            it "doesn't raise an error" do
              expect { RPi::GPIO.setup 18, :as => :input, :pull => :down }
                .to_not raise_error
            end
          end

          context "given invalid pull direction" do
            it "raises an error" do
              expect { RPi::GPIO.setup 18, :as => :input, :pull => :nope }
                .to raise_error ArgumentError
            end
          end
        end

        context "as output" do
          context "given no pull direction" do
            it "doesn't raise an error" do
              expect { RPi::GPIO.setup 18, :as => :output } .to_not raise_error
            end
          end

          context "given a pull direction" do
            it "raises an error" do
              expect { RPi::GPIO.setup 18, :as => :output, :pull => :down }
                .to raise_error ArgumentError
            end
          end
        end
      end

      context "given a valid channel set to the same direction" do
        before :each do
          RPi::GPIO.setup 18, :as => :input
        end

        it "doesn't raise an error" do
          expect { RPi::GPIO.setup 18, :as => :input } .to_not raise_error
        end

        it "doesn't affect the channel's usage" do
          RPi::GPIO.setup 18, :as => :input
          expect { RPi::GPIO.high? 18 } .to_not raise_error
        end
      end

      context "given a valid channel set to the opposite direction" do
        before :each do
          RPi::GPIO.setup 18, :as => :output
          expect { RPi::GPIO.high? 18 } .to_not raise_error
        end

        it "doesn't raise an error" do
          expect { RPi::GPIO.setup 18, :as => :input } .to_not raise_error
        end

        it "affects the channel's usage" do
          RPi::GPIO.setup 18, :as => :input
          expect { RPi::GPIO.high? 18 } .to_not raise_error
        end
      end

      context "given an invalid channel" do
        it "raises an error" do
          expect { RPi::GPIO.setup 0, :as => :input }
            .to raise_error ArgumentError
        end
      end

      context "given multiple valid, unset channels" do
        context "as input" do
          context "given no pull direction" do
            it "doesn't raise an error" do
              expect { RPi::GPIO.setup [18, 19], :as => :input } .to_not raise_error
            end
          end

          context "given :off pull direction" do
            it "doesn't raise an error" do
              expect { RPi::GPIO.setup [18, 19], :as => :input, :pull => :off }
                .to_not raise_error
            end
          end

          context "given :up pull direction" do
            it "doesn't raise an error" do
              expect { RPi::GPIO.setup [18, 19], :as => :input, :pull => :up }
                .to_not raise_error
            end
          end

          context "given :down pull direction" do
            it "doesn't raise an error" do
              expect { RPi::GPIO.setup [18, 19], :as => :input, :pull => :down }
                .to_not raise_error
            end
          end

          context "given invalid pull direction" do
            it "raises an error" do
              expect { RPi::GPIO.setup [18, 19], :as => :input, :pull => :nope }
                .to raise_error ArgumentError
            end
          end
        end

        context "as output" do
          context "given no pull direction" do
            it "doesn't raise an error" do
              expect { RPi::GPIO.setup [18, 19], :as => :output } .to_not raise_error
            end
          end

          context "given a pull direction" do
            it "raises an error" do
              expect { RPi::GPIO.setup [18, 19], :as => :output, :pull => :down }
                .to raise_error ArgumentError
            end
          end
        end
      end

      context "given multiple channels with one invalid" do
        it "raises an error" do
          expect { RPi::GPIO.setup [0, 18], :as => :input }
            .to raise_error ArgumentError
        end
      end
    end
  end

  describe "set_high" do
    context "before numbering is set" do
      it "raises an error" do
        expect { RPi::GPIO.set_high 18 } .to raise_error RuntimeError
      end
    end

    context "after numbering is set" do
      before :each do
        RPi::GPIO.set_numbering :board
      end

      context "given a valid output channel" do
        before :each do
          RPi::GPIO.setup 18, :as => :output
        end

        it "doesn't raise an error" do
          expect { RPi::GPIO.set_high 18 } .to_not raise_error
        end
      end

      context "given a valid input channel" do
        before :each do
          RPi::GPIO.setup 18, :as => :input
        end

        it "raises an error" do
          expect { RPi::GPIO.set_high 18 } .to raise_error RuntimeError
        end
      end

      context "given a valid, unset channel" do
        it "raises an error" do
          expect { RPi::GPIO.set_high 18 } .to raise_error RuntimeError
        end
      end

      context "given an invalid channel" do
        it "raises an error" do
          expect { RPi::GPIO.set_high 0 } .to raise_error ArgumentError
        end
      end

      context "with multiple pins" do
        context "given a valid output channel" do
          before :each do
            RPi::GPIO.setup [18, 19], :as => :output
          end

          it "doesn't raise an error" do
            expect { RPi::GPIO.set_high [18, 19] } .to_not raise_error
          end
        end

        context "given a valid input channel" do
          before :each do
            RPi::GPIO.setup [18, 19], :as => :input
          end

          it "raises an error" do
            expect { RPi::GPIO.set_high [18, 19] } .to raise_error RuntimeError
          end
        end

        context "given a valid, unset channel" do
          it "raises an error" do
            expect { RPi::GPIO.set_high [18, 19] } .to raise_error RuntimeError
          end
        end

        context "given an invalid channel" do
          it "raises an error" do
            expect { RPi::GPIO.set_high [0, 18] } .to raise_error ArgumentError
          end
        end
      end
    end
  end

  describe "set_low" do
    context "before numbering is set" do
      it "raises an error" do
        expect { RPi::GPIO.set_low 18 } .to raise_error RuntimeError
      end
    end

    context "after numbering is set" do
      before :each do
        RPi::GPIO.set_numbering :board
      end

      context "given a valid output channel" do
        before :each do
          RPi::GPIO.setup 18, :as => :output
        end

        it "doesn't raise an error" do
          expect { RPi::GPIO.set_low 18 } .to_not raise_error
        end
      end

      context "given a valid input channel" do
        before :each do
          RPi::GPIO.setup 18, :as => :input
        end

        it "raises an error" do
          expect { RPi::GPIO.set_low 18 } .to raise_error RuntimeError
        end
      end

      context "given a valid, unset channel" do
        it "raises an error" do
          expect { RPi::GPIO.set_low 18 } .to raise_error RuntimeError
        end
      end

      context "given an invalid channel" do
        it "raises an error" do
          expect { RPi::GPIO.set_low 0 } .to raise_error ArgumentError
        end
      end

      context "with multiple channels" do
        context "given a valid output channel" do
          before :each do
            RPi::GPIO.setup [18, 19], :as => :output
          end

          it "doesn't raise an error" do
            expect { RPi::GPIO.set_low [18, 19] } .to_not raise_error
          end
        end

        context "given a valid input channel" do
          before :each do
            RPi::GPIO.setup [18, 19], :as => :input
          end

          it "raises an error" do
            expect { RPi::GPIO.set_low [18, 19] } .to raise_error RuntimeError
          end
        end

        context "given a valid, unset channel" do
          it "raises an error" do
            expect { RPi::GPIO.set_low [18, 19] } .to raise_error RuntimeError
          end
        end

        context "given an invalid channel" do
          it "raises an error" do
            expect { RPi::GPIO.set_low [0, 18] } .to raise_error ArgumentError
          end
        end
      end
    end
  end

  describe "high?" do
    context "before numbering is set" do
      it "raises an error" do
        expect { RPi::GPIO.high? 18 } .to raise_error RuntimeError
      end
    end

    context "after numbering is set" do
      before :each do
        RPi::GPIO.set_numbering :board
      end

      context "given a valid input channel" do
        before :each do
          RPi::GPIO.setup 18, :as => :input
        end

        it "doesn't raise an error" do
          expect { RPi::GPIO.high? 18 } .to_not raise_error
        end
      end

      context "given a valid output channel" do
        before :each do
          RPi::GPIO.setup 18, :as => :output
        end

        it "doesn't raise an error" do
          expect { RPi::GPIO.high? 18 } .to_not raise_error
        end
      end

      context "given a valid, unset channel" do
        it "raises an error" do
          expect { RPi::GPIO.high? 18 } .to raise_error RuntimeError
        end
      end

      context "given an invalid channel" do
        it "raises an error" do
          expect { RPi::GPIO.high? 0 } .to raise_error ArgumentError
        end
      end
    end
  end

  describe "low?" do
    context "before numbering is set" do
      it "raises an error" do
        expect { RPi::GPIO.low? 18 } .to raise_error RuntimeError
      end
    end

    context "after numbering is set" do
      before :each do
        RPi::GPIO.set_numbering :board
      end

      context "given a valid input channel" do
        before :each do
          RPi::GPIO.setup 18, :as => :input
        end

        it "doesn't raise an error" do
          expect { RPi::GPIO.low? 18 } .to_not raise_error
        end
      end

      context "given a valid output channel" do
        before :each do
          RPi::GPIO.setup 18, :as => :output
        end

        it "doesn't raise an error" do
          expect { RPi::GPIO.low? 18 } .to_not raise_error
        end
      end

      context "given a valid, unset channel" do
        it "raises an error" do
          expect { RPi::GPIO.low? 18 } .to raise_error RuntimeError
        end
      end

      context "given an invalid channel" do
        it "raises an error" do
          expect { RPi::GPIO.low? 0 } .to raise_error ArgumentError
        end
      end
    end
  end

  describe "watch" do
    context "before numbering is set" do
      it "raises an error" do
        expect { RPi::GPIO.watch(11, :on => :rising) { |pin, value| } } .to raise_error RuntimeError
      end
    end

    context "after numbering is set" do
      before :each do
        RPi::GPIO.set_numbering :board
      end

      context "given a valid output channel" do
        before :each do
          RPi::GPIO.setup 11, :as => :output
        end

        it "raises an error" do
          expect { RPi::GPIO.watch(11, :on => :rising) { |pin, value| } } .to raise_error RuntimeError
        end
      end

      context "given a valid input channel" do
        before :each do
          RPi::GPIO.setup 11, :as => :input
        end

        context "that isn't being watched yet" do
          it "accepts :rising" do
            expect { RPi::GPIO.watch(11, :on => :rising) { |pin, value| } } .to_not raise_error
          end

          it "accepts :falling" do
            expect { RPi::GPIO.watch(11, :on => :falling) { |pin, value| } } .to_not raise_error
          end

          it "accepts :both" do
            expect { RPi::GPIO.watch(11, :on => :both) { |pin, value| } } .to_not raise_error
          end

          it "accepts a numeric bounce_time" do
            expect { RPi::GPIO.watch(11, :on => :rising, :bounce_time => 200) { |pin, value| } }
              .to_not raise_error
          end
        end

        context "that's already being watched" do
          before :each do
            RPi::GPIO.watch(11, :on => :rising) { |pin, value| } 
          end

          it "raises an error" do
            expect { RPi::GPIO.watch(11, :on => :rising) { |pin, value| } } .to raise_error RuntimeError
          end
        end
      end

      context "given a valid, unset channel" do
        it "raises an error" do
          expect { RPi::GPIO.watch(11, :on => :rising) { |pin, value| } } .to raise_error RuntimeError
        end
      end

      context "given an invalid channel" do
        it "raises an error" do
          expect { RPi::GPIO.watch(0, :on => :rising) { |pin, value| } } .to raise_error ArgumentError
        end
      end
    end
  end

  describe "stop_watching" do
    context "before numbering is set" do
      it "raises an error" do
        expect { RPi::GPIO.stop_watching 11 } .to raise_error RuntimeError
      end
    end

    context "after numbering is set" do
      before :each do
        RPi::GPIO.set_numbering :board
      end

      context "given a valid output channel" do
        before :each do
          RPi::GPIO.setup 11, :as => :output
        end

        it "raises an error" do
          expect { RPi::GPIO.stop_watching 11 } .to raise_error RuntimeError
        end
      end

      context "given a valid input channel" do
        before :each do
          RPi::GPIO.setup 11, :as => :input
        end

        context "that isn't being watched yet" do
          it "doesn't raise an error" do
            expect { RPi::GPIO.stop_watching 11 } .to_not raise_error
          end
        end

        context "that's being watched" do
          before :each do
            RPi::GPIO.watch(11, :on => :rising) { |pin, value| } 
          end

          it "doesn't raise an error" do
            expect { RPi::GPIO.stop_watching 11 } .to_not raise_error
          end

          it "lets the user re-watch the channel" do
            RPi::GPIO.stop_watching 11 
            expect { RPi::GPIO.watch(11, :on => :rising) { |pin, value|  } } .to_not raise_error
          end
        end
      end

      context "given a valid, unset channel" do
        it "raises an error" do
          expect { RPi::GPIO.stop_watching 11 } .to raise_error RuntimeError
        end
      end

      context "given an invalid channel" do
        it "raises an error" do
          expect { RPi::GPIO.stop_watching 0 } .to raise_error ArgumentError
        end
      end
    end
  end

  describe "wait_for_edge" do
    context "before numbering is set" do
      it "raises an error" do
        expect { RPi::GPIO.wait_for_edge 11, :rising } .to raise_error RuntimeError
      end
    end

    context "after numbering is set" do
      before :each do
        RPi::GPIO.set_numbering :board
      end

      context "given a valid output channel" do
        before :each do
          RPi::GPIO.setup 11, :as => :output
        end

        it "raises an error" do
          expect { RPi::GPIO.wait_for_edge 11, :rising } .to raise_error RuntimeError
        end
      end

      context "given a valid input channel" do
        before :each do
          RPi::GPIO.setup 11, :as => :input
        end

        context "that isn't being watched yet" do
          it "accepts :rising" do
            expect { RPi::GPIO.wait_for_edge 11, :rising, :timeout => 100 } .to_not raise_error
          end

          it "accepts :falling" do
            expect { RPi::GPIO.wait_for_edge 11, :falling, :timeout => 100 } .to_not raise_error
          end

          it "accepts :both" do
            expect { RPi::GPIO.wait_for_edge 11, :both, :timeout => 100 } .to_not raise_error
          end

          it "returns nil on timeout" do
            RPi::GPIO.wait_for_edge(11, :both, :timeout => 100).should eq nil
          end
        end

        context "that's being watched" do
          before :each do
            RPi::GPIO.watch(11, :on => :rising) { |pin, value| } 
          end

          it "doesn't raise an error" do
            expect { RPi::GPIO.stop_watching 11 } .to_not raise_error
          end

          it "lets the user re-watch the channel" do
            RPi::GPIO.stop_watching 11 
            expect { RPi::GPIO.watch(11, :on => :rising) { |pin, value|  } } .to_not raise_error
          end
        end
      end

      context "given a valid, unset channel" do
        it "raises an error" do
          expect { RPi::GPIO.stop_watching 11 } .to raise_error RuntimeError
        end
      end

      context "given an invalid channel" do
        it "raises an error" do
          expect { RPi::GPIO.stop_watching 0 } .to raise_error ArgumentError
        end
      end
    end
  end
end
