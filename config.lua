Config = {
    Notify = 'ox',        -- 'qb', 'ox', 'snappy-phone', 'lb-phone', 'yseries'
    Phone = 'lb-phone',   -- 'snappy-phone', 'lb-phone', 'yseries'
    TaxAccount = 'state', -- account where all the tax goes to
    Taxation = {
        low = { amount = 100000, percent = 0.01 },
        medium = { amount = 250000, percent = 0.02 },
        high = { amount = 500000, percent = 0.03 },
        ultra = { amount = 1000000, percent = 0.04 },
        extreme = { amount = 2000000, percent = 0.05 },
    },
    CardFeeAccount = 'banker', -- account where the fee amount goes
    CardPaymentFee = 0.025,    -- (percentage) 0.025 = 2.5% [false to disable this]
    POSCommissions = {         -- Name | Commission is a percentage eg "0.10" becomes 10%
        police = 0.10,
        ambulance = 0.10,
        mechanic = 0.20,
    },
    RegisterComissions = { -- Name | Commission is a percentage eg "0.10" becomes 10%
        police = 0.10,
        ambulance = 0.10,
        mechanic = 0.20,
    },
    Registers = { -- Locations where payment counter exists
        {
            job = 'mechanic',
            name = "LS Customs [Register 1]",
            coords = vector3(-343.58, -140.1, 39.01),
            distance = 3
        }
    }
}
