require_relative "spec_helper"

describe "RPi::GPIO::PWM" do
  before :each do
    RPi::GPIO.set_warnings false
    RPi::GPIO.reset
    RPi::GPIO.set_warnings false
  end

  after :each do
    RPi::GPIO.set_warnings false
    RPi::GPIO.reset
  end

  describe "#initialize" do
    context "before numbering is set" do
      it "raises an error" do
        expect { RPi::GPIO::PWM.new(18, 100) } .to raise_error RuntimeError
      end
    end

    context "after numbering is set" do
      before :each do
        RPi::GPIO.set_numbering :board
      end

      context "given an invalid channel" do
        it "raises an error" do
          expect { RPi::GPIO::PWM.new(0, 100) } .to raise_error ArgumentError
        end
      end

      context "given a valid unset channel" do
        it "raises an error" do
          expect { RPi::GPIO::PWM.new(18, 100) } .to raise_error RuntimeError
        end
      end

      context "given a valid input channel" do
        before :each do
          RPi::GPIO.setup 18, :as => :input
        end

        it "raises an error" do
          expect { RPi::GPIO::PWM.new(18, 100) } .to raise_error RuntimeError
        end
      end

      context "given a valid output channel" do
        before :each do
          RPi::GPIO.setup 18, :as => :output
        end

        context "with a valid frequency" do
          let(:pwm) { RPi::GPIO::PWM.new(18, 100) }

          after :each do
            pwm.stop
          end

          it "doesn't raise an error" do
            expect { pwm } .to_not raise_error
          end

          it "returns a PWM object" do
            expect(pwm).to be_a RPi::GPIO::PWM
          end
        end

        context "with an invalid frequency" do
          it "raises an error" do
            expect { RPi::GPIO::PWM.new(18, 0) } .to raise_error ArgumentError
          end
        end
      end
    end
  end

  describe "#start" do
    before :each do
      RPi::GPIO.set_numbering :board
      RPi::GPIO.setup 18, :as => :output
    end

    let(:pwm) { RPi::GPIO::PWM.new(18, 100) }

    after :each do
      pwm.stop
    end

    context "given a valid duty cycle" do
      let(:start) { pwm.start(65) }

      it "doesn't raise an error" do
        expect { start } .to_not raise_error
      end

      it "sets the PWM's duty cycle" do
        start
        expect(pwm.duty_cycle).to eq 65
      end

      it "sets the PWM's running status to true" do
        expect { start } .to change { pwm.running? } .from(false).to(true)
      end
    end

    context "given a duty cycle less than 0" do
      let(:start) { pwm.start(-1) }

      it "raises an error" do
        expect { start } .to raise_error ArgumentError
      end

      it "doesn't set the PWM's duty cycle" do
        start rescue nil
        expect(pwm.duty_cycle).to_not eq -1
      end
    end

    context "given a duty cycle greater than 100" do
      let(:start) { pwm.start(101) }

      it "raises an error" do
        expect { start } .to raise_error ArgumentError
      end

      it "doesn't set the PWM's duty cycle" do
        start rescue nil
        expect(pwm.duty_cycle).to_not eq 101
      end
    end
  end

  describe "#gpio" do
    before :each do
      RPi::GPIO.set_numbering :board
      RPi::GPIO.setup 18, :as => :output
    end

    let(:pwm) { RPi::GPIO::PWM.new(18, 100) }

    after :each do
      pwm.stop
    end

    # pin number is 18, but GPIO number is 24
    it "gives the associated GPIO number" do
      expect(pwm.gpio).to eq 24
    end
  end

  describe "#duty_cycle" do
    before :each do
      RPi::GPIO.set_numbering :board
      RPi::GPIO.setup 18, :as => :output
    end

    let(:pwm) do
      p = RPi::GPIO::PWM.new(18, 100)
      p.start(5)
      p
    end

    after :each do
      pwm.stop
    end

    it "gives the current duty cycle" do
      expect(pwm.duty_cycle).to eq 5
    end
  end

  describe "#duty_cycle=" do
    before :each do
      RPi::GPIO.set_numbering :board
      RPi::GPIO.setup 18, :as => :output
    end

    let(:pwm) do
      p = RPi::GPIO::PWM.new(18, 100)
      p.start(5)
      p
    end

    after :each do
      pwm.stop
    end

    context "given a valid duty cycle" do
      it "correctly sets the duty cycle" do
        expect { pwm.duty_cycle = 15 } .to change { pwm.duty_cycle } 
          .from(5).to(15)
      end
    end

    context "given a duty cycle less than 0" do
      let(:set) { pwm.duty_cycle = -1 }

      it "raises an error" do
        expect { set } .to raise_error ArgumentError
      end
      
      it "doesn't set the duty cycle" do
        set rescue nil
        expect(pwm.duty_cycle).to_not eq -1
      end
    end
    
    context "given a duty cycle greater than 100" do
      let(:set) { pwm.duty_cycle = 101 }

      it "raises an error" do
        expect { set } .to raise_error ArgumentError
      end
      
      it "doesn't set the duty cycle" do
        set rescue nil
        expect(pwm.duty_cycle).to_not eq 101
      end
    end
  end

  describe "#frequency" do
    before :each do
      RPi::GPIO.set_numbering :board
      RPi::GPIO.setup 18, :as => :output
    end

    let(:pwm) { RPi::GPIO::PWM.new(18, 100) }

    after :each do
      pwm.stop
    end

    it "gives the current frequency" do
      expect(pwm.frequency).to eq 100
    end
  end

  describe "#frequency=" do
    before :each do
      RPi::GPIO.set_numbering :board
      RPi::GPIO.setup 18, :as => :output
    end

    let(:pwm) do
      p = RPi::GPIO::PWM.new(18, 100)
      p.start(5)
      p
    end

    after :each do
      pwm.stop
    end

    context "given a valid frequency" do
      it "correctly sets the frequency" do
        expect { pwm.frequency = 15 } .to change { pwm.frequency } 
          .from(100).to(15)
      end
    end

    context "given a frequency less than 0" do
      let(:set) { pwm.frequency = -1 }

      it "raises an error" do
        expect { set } .to raise_error ArgumentError
      end
      
      it "doesn't set the frequency" do
        set rescue nil
        expect(pwm.frequency).to_not eq -1
      end
    end
  end

  describe "#stop" do
    before :each do
      RPi::GPIO.set_numbering :board
      RPi::GPIO.setup 18, :as => :output
    end

    let(:pwm) do
      p = RPi::GPIO::PWM.new(18, 100)
      p.start(5)
      p
    end

    after :each do
      pwm.stop
    end

    it "sets the PWM's running status to false" do
      expect { pwm.stop } .to change { pwm.running? } .from(true).to(false)
    end
  end
end
