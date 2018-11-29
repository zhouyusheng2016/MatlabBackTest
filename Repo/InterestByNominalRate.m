function interest = InterestByNominalRate(Principle, NominalRatePrice, Period)

rateOfInterest = NominalRatePrice/100/(365/Period);

interest = Principle*rateOfInterest;

end