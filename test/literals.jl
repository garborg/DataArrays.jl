module TestLiterals
    using Base.Test
    using DataArrays

    dv = @data [1, NA, 3]
    @test isequal(dv,
                  DataArray([1, 0, 3],
                            [false, true, false]))

    dm = @data [1 NA; 3 4]
    @test isequal(dm,
                  DataArray([1 0; 3 4],
                            [false true; false false]))

    dm = @data [1 NA;
                3 4]
    @test isequal(dm,
                  DataArray([1 0; 3 4],
                            [false true; false false]))

    pdv = @pdata [1, NA, 3]
    @test isequal(pdv,
                  PooledDataArray([1, 0, 3],
                                  [false, true, false]))

    pdm = @pdata [1 NA; 3 4]
    @test isequal(pdm,
                  PooledDataArray([1 0; 3 4],
                                  [false true; false false]))

    pdm = @pdata [1 NA;
                3 4]
    @test isequal(pdm,
                  PooledDataArray([1 0; 3 4],
                                  [false true; false false]))

    dv1 = @data zeros(4)
    dv2 = @data ones(4)
    dv3 = @data rand(4)

    dm1 = @data zeros(4, 4)
    dm2 = @data ones(4, 4)
    dm3 = @data rand(4, 4)

    pdv1 = @pdata zeros(4)
    pdv2 = @pdata ones(4)
    pdv3 = @pdata rand(4)

    pdm1 = @pdata zeros(4, 4)
    pdm2 = @pdata ones(4, 4)
    pdm3 = @pdata rand(4, 4)

    mixed1 = @data ["x", 1, 1.23, NA]
    mixed2 = @data [NA, "x", 1, 1.23, NA]

    @test isequal(mixed1, DataArray({"x", 1, 1.23, 0},
                                    [false, false, false, true]))
    @test isequal(mixed2, DataArray({NA, "x", 1, 1.23, 0},
                                    [true, false, false, false, true]))

    x = 5.1
    ex = :([1, 2, 3])
    DataArrays.parsedata(ex)
    @test isequal(@data([1, 2, 3]),
                  DataArray([1, 2, 3], [false, false, false]))

    ex = :([1, 2, 3.0])
    DataArrays.parsedata(ex)
    @test isequal(@data([1, 2, 3.0]),
                  DataArray([1, 2, 3.0], [false, false, false]))

    ex = :([1, 2, x])
    DataArrays.parsedata(ex)
    @test isequal(@data([1, 2, x]),
                  DataArray([1, 2, x], [false, false, false]))

    ex = :([1, 2, NA])
    DataArrays.parsedata(ex)
    @test isequal(@data([1, 2, NA]),
                  DataArray([1, 2, 1], [false, false, true]))

    ex = :([1, 2, x, NA])
    DataArrays.parsedata(ex)
    @test isequal(@data([1, 2, x, NA]),
                  DataArray([1, 2, x, 1], [false, false, false, true]))

    # Matrices
    ex = :([1 2; 3 4])
    DataArrays.parsedata(ex)
    @data([1 2; 3 4])
    @test isequal(@data([1 2; 3 4]),
                  DataArray([1 2; 3 4], [false false; false false]))

    ex = :([1 2; 3.0 4])
    DataArrays.parsedata(ex)
    @test isequal(@data([1 2; 3.0 4]),
                  DataArray([1 2; 3.0 4], [false false; false false]))

    ex = :([1 2; x x])
    DataArrays.parsedata(ex)
    @test isequal(@data([1 2; x x]),
                  DataArray([1 2; x x], [false false; false false]))

    ex = :([1 2; NA NA])
    DataArrays.parsedata(ex)
    @test isequal(@data([1 2; NA NA]),
                  DataArray([1 2; 1 1], [false false; true true]))

    ex = :([1 2; x NA])
    DataArrays.parsedata(ex)
    @test isequal(@data([1 2; x NA]),
                  DataArray([1 2; x 1], [false false; false true]))

    # Complex vector expressions
    ex = :([1 + 1, 2 + 2, x * x, NA])
    DataArrays.parsedata(ex)
    @test isequal(@data([1 + 1, 2 + 2, x * x, NA]),
                  DataArray([1 + 1, 2 + 2, x * x, 1],
                            [false, false, false, true]))

    ex = :([sin(1), cos(2) + cos(2), exp(x * x), sum([1, 1, 1])])
    DataArrays.parsedata(ex)
    @test isequal(@data([sin(1),
                         cos(2) + cos(2),
                         exp(x * x),
                         sum([1, 1, 1])]),
                  DataArray([sin(1),
                             cos(2) + cos(2),
                             exp(x * x),
                             sum([1, 1, 1])],
                            [false, false, false, false]))

    ex = :([1 + 1im, 2 + 2im])
    DataArrays.parsedata(ex)
    @test isequal(@data([1 + 1im, 2 + 2im]),
                  DataArray([1 + 1im, 2 + 2im],
                            [false, false]))

    # Complex matrix expressions
    ex = :([1 + 1 2 + 2; x * x NA])
    DataArrays.parsedata(ex)
    @test isequal(@data([1 + 1 2 + 2; x * x NA]),
                  DataArray([1 + 1 2 + 2; x * x 1],
                            [false false; false true]))

    ex = :([sin(1) cos(2) + cos(2);
            exp(x * x) sum([1, 1, 1])])
    DataArrays.parsedata(ex)
    @test isequal(@data([sin(1) cos(2) + cos(2);
                        exp(x * x) sum([1, 1, 1])]),
                  DataArray([sin(1) cos(2) + cos(2);
                             exp(x * x) sum([1, 1, 1])],
                            [false false;
                             false false]))

    @test isequal(DataArrays.fixargs(:([1, 2, NA, x]).args, -1),
                  ({1, 2, -1, :x}, {false, false, true, false}))

    @test isequal(DataArrays.findstub_vector(:([1, 2, NA, x])), 1)
    @test isequal(DataArrays.findstub_vector(:([NA, NA, NA, x])), :x)

    # Lots of variables
    a, b, c, d = 1, 2, 3, 4
    @data [a, b, c, d]
end
