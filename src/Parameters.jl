module Parameters

# working fluid setup
const SLUGNUM_DEFAULT = Ref(30); # original, generally too high
const CHARGE_RATIO_DEFAULT = Ref(0.46) # for ASETSII
const NUCLEATENUM_DEFAULT = Ref(250); # for a ~4m tube, that's 1 per 16mm; seems too small
const RN_BOIL_DEFAULT = Ref(3e-6); # changes dTsuperheat, bigger RN -> smaller dT (approx. linear)
const FILM_FRACTION_DEFAULT = Ref(0.9); # was 0.3...not sure why
const BOIL_WAITING_TIME_DEFAULT = Ref(1.0); # was 1.0, seems big.

export SLUGNUM_DEFAULT, CHARGE_RATIO_DEFAULT, NUCLEATENUM_DEFAULT, RN_BOIL_DEFAULT, FILM_FRACTION_DEFAULT, BOIL_WAITING_TIME_DEFAULT

end
